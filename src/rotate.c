#include <stdint.h>
#include <stdio.h>
#include <zlib.h>
#include <assert.h>

#include "kseq.h"

KSEQ_INIT(gzFile, gzread)

uint8_t seq_nt4_table[] = {
        [0 ... 128] = 0, [65] = 1, [67] = 2, [71] = 3, [84] = 4,
        [97] = 1, [99] = 2, [103] = 3, [116] = 4};

typedef struct {
    int score;
    int start;
} dpr_t;

static inline unsigned int min(unsigned int a, unsigned int b, unsigned int c) {
    unsigned int m = a;
    if (m > b)
        m = b;
    if (m > c)
        m = c;
    return m;
}

dpr_t nw(uint8_t *s1, uint32_t l1, uint8_t *s2, uint32_t l2) {
    int c, r;
    int cols = l1;
    int rows = l2;

    uint **mat = (uint32_t **) malloc(rows * sizeof(uint32_t * ));
    for (r = 0; r < rows; ++r)
        mat[r] = (uint32_t *) malloc(cols * sizeof(uint32_t));

    // Base cases
    for (r = 0; r < rows; ++r)
        mat[r][0] = r;
    for (c = 0; c < cols; ++c)
        mat[0][c] = 0;

    // Fill matrix
    for (c = 1; c < cols; ++c) {
        for (r = 1; r < rows; ++r) {
            mat[r][c] = min(mat[r - 1][c] + 1, mat[r][c - 1] + 1,
                            mat[r - 1][c - 1] + (s1[c] != s2[r]));
        }
    }
    // Get best score from last row
    int score = INT32_MAX;
    int best_c = -1;
    for (c = 0; c < cols; ++c) {
        if (mat[rows - 1][c] < score) {
            score = mat[rows - 1][c];
            best_c = c;
        }
    }
    // printf("Score: %d. At column %d\n", score, best_c);

    // Backtrack
    r = rows - 1;
    c = best_c;
    while (r != 0) {
        if (mat[r - 1][c - 1] <= mat[r - 1][c] && mat[r - 1][c - 1] <= mat[r][c - 1]) {
            --r;
            --c;
        } else if (mat[r][c - 1] <= mat[r - 1][c - 1] && mat[r][c - 1] <= mat[r - 1][c]) {
            --c;
        } else if (mat[r - 1][c] <= mat[r - 1][c - 1] && mat[r - 1][c] <= mat[r][c - 1]) {
            --r;
        }
    }
    best_c = c;
    // printf("Best start at %d\n", best_c);

    for (r = 0; r < rows; ++r) {
//        for (c = 0; c < cols; ++c)
//            printf("%d\t", mat[r][c]);
//        printf("\n");
        free(mat[r]);
    }
    free(mat);
    return (dpr_t) {score, best_c};
}


int main(int argc, char *argv[]) {
    char *fp1 = argv[1];
    char *fp2 = argv[2];

    gzFile fp = gzopen(fp1, "rb");
    kseq_t *ks = kseq_init(fp);
    int l;
    uint8_t *rs = 0;
    uint rsl = 0;
    int i;
    while ((l = kseq_read(ks)) >= 0) {
        rsl = l;
        rs = calloc(rsl + 1, sizeof(uint8_t));
        memcpy(rs, ks->seq.s, rsl);
        rs[rsl] = '\0';
        // change encoding
        for (i = 0; i < rsl; ++i)
            rs[i] = rs[i] < 128 ? seq_nt4_table[rs[i]] : 0;
    }
    kseq_destroy(ks);
    gzclose(fp);

//    for (i = 0; i < rsl; ++i)
//        printf("%d", (int) rs[i]);
//    printf("\n");

    fp = gzopen(fp2, "rb");
    ks = kseq_init(fp);
    uint8_t *qs = calloc(3 * rsl, sizeof(uint8_t));
    uint8_t *qs_rc = calloc(3 * rsl, sizeof(uint8_t));
    uint8_t *qs_rot = calloc(3 * rsl, sizeof(uint8_t));
    dpr_t res, res_rc;
    while ((l = kseq_read(ks)) >= 0) {
        assert(2 * l < 3 * rsl);
        memcpy(qs, ks->seq.s, l);
        memcpy(qs + l, ks->seq.s, l);
        qs[2 * l] = '\0';

        // change encoding
        for (i = 0; i < 2 * l; ++i)
            qs[i] = qs[i] < 128 ? seq_nt4_table[qs[i]] : 0;
        res = nw(qs, 2 * l, rs, rsl);

        // reverse and complement
        for (i = 0; i < (l >> 1); ++i) {
            int tmp = qs[l - 1 - i];
            tmp = (tmp >= 1 && tmp <= 4) ? 5 - tmp : tmp;
            qs_rc[l - 1 - i] = (qs[i] >= 1 && qs[i] <= 4) ? 5 - qs[i] : qs[i];
            qs_rc[i] = tmp;
        }
        if (l & 1)
            qs_rc[i] = (qs[i] >= 1 && qs[i] <= 4) ? 5 - qs[i] : qs[i];
        qs_rc[2*l] = '\0';

        res_rc = nw(qs_rc, 2 * l, rs, rsl);

        if (res.score <= res_rc.score) {
            memcpy(qs_rot, qs + res.start, l - res.start);
            if (res.start > 0)
                memcpy(qs_rot + l - res.start, qs, res.start);
            printf(">%s START:%d STRAND:+ SCORE:%d\n", ks->name.s, res.start, res.score);
            for(i=0; i<l; ++i)
                putchar("NACGT"[qs_rot[i]]);
            putchar('\n');
        } else {
            memcpy(qs_rot, qs_rc + res_rc.start, l - res_rc.start);
            if (res_rc.start > 0)
                memcpy(qs_rot + l - res_rc.start, qs_rc, res_rc.start);
            printf(">%s START:%d STRAND:- SCORE:%d\n", ks->name.s, res_rc.start, res_rc.score);
            for(i=0; i<l; ++i)
                putchar("NACGT"[qs_rot[i]]);
            putchar('\n');
        }
    }
    kseq_destroy(ks);
    gzclose(fp);

    free(rs);
    free(qs);
    free(qs_rc);
    free(qs_rot);

    return 0;
}
