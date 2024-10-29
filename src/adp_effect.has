*=======================================================
*
*	ＩＯＣＳ各周波数ADPCM->PCM変換
*
*=======================================================

AtoP_EFCT01_08:	sub.l		#MIX_SIZE/8,EFCT_PCM_LEN(a5)	* 1/8再生
		bgt		@f
		bsr		AtoP_EFCT_end		* 軽さ重視です。すまん。

@@:		move.w		EFCT_AtoP_Y(a5),d1	* d1.w = PCM予測値
		movea.l		EFCT_PCM_ADR(a5),a0	* a0.l = ADPCMアドレス
		movea.l		EFCT_AtoP_X(a5),a2	* a2.l = ADPCM->PCM変換テーブルアドレス

		moveq.l		#MIX_SIZE/8-1,d6	* ADPCM -> PCM 変換

1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		256*2(a2),d1		* (12)
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		adda.w		256*2*2(a2),a2		* (16)

		dbra		d6,1b

		move.w		d1,EFCT_AtoP_Y(a5)	* d1.w = PCM予測値
		move.l		a0,EFCT_PCM_ADR(a5)	* a0.l = ADPCMアドレス
		move.l		a2,EFCT_AtoP_X(a5)	* a2.l = ADPCM->PCM変換テーブルアドレス

		rts

AtoP_EFCT01_06:	sub.l		#MIX_SIZE/6,EFCT_PCM_LEN(a5)	* 1/6再生
		bgt		@f
		bsr		AtoP_EFCT_end

@@:		move.w		EFCT_AtoP_Y(a5),d1	* d1.w = PCM予測値
		movea.l		EFCT_PCM_ADR(a5),a0	* a0.l = ADPCMアドレス
		movea.l		EFCT_AtoP_X(a5),a2	* a2.l = ADPCM->PCM変換テーブルアドレス

		moveq.l		#MIX_SIZE/6-1,d6	* ADPCM -> PCM 変換

1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		256*2(a2),d1		* (12)
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		adda.w		256*2*2(a2),a2		* (16)

		dbra		d6,1b

		move.w		d1,EFCT_AtoP_Y(a5)	* d1.w = PCM予測値
		move.l		a0,EFCT_PCM_ADR(a5)	* a0.l = ADPCMアドレス
		move.l		a2,EFCT_AtoP_X(a5)	* a2.l = ADPCM->PCM変換テーブルアドレス

		rts

AtoP_EFCT01_04:	sub.l		#MIX_SIZE/4,EFCT_PCM_LEN(a5)	* 1/4再生(3.9kHz)
		bgt		@f
		bsr		AtoP_EFCT_end		* 軽さ重視です。すまん。

@@:		move.w		EFCT_AtoP_Y(a5),d1	* d1.w = PCM予測値
		movea.l		EFCT_PCM_ADR(a5),a0	* a0.l = ADPCMアドレス
		movea.l		EFCT_AtoP_X(a5),a2	* a2.l = ADPCM->PCM変換テーブルアドレス

		moveq.l		#MIX_SIZE/4-1,d6	* ADPCM -> PCM 変換

1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		256*2(a2),d1		* (12)
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		adda.w		256*2*2(a2),a2		* (16)

		dbra		d6,1b

		move.w		d1,EFCT_AtoP_Y(a5)	* d1.w = PCM予測値
		move.l		a0,EFCT_PCM_ADR(a5)	* a0.l = ADPCMアドレス
		move.l		a2,EFCT_AtoP_X(a5)	* a2.l = ADPCM->PCM変換テーブルアドレス

		rts

AtoP_EFCT01_03:	sub.l		#MIX_SIZE/3,EFCT_PCM_LEN(a5)	* 1/3再生(5.2kHz)
		bgt		@f
		bsr		AtoP_EFCT_end

@@:		move.w		EFCT_AtoP_Y(a5),d1	* d1.w = PCM予測値
		movea.l		EFCT_PCM_ADR(a5),a0	* a0.l = ADPCMアドレス
		movea.l		EFCT_AtoP_X(a5),a2	* a2.l = ADPCM->PCM変換テーブルアドレス

		moveq.l		#MIX_SIZE/3-1,d6	* ADPCM -> PCM 変換

1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		256*2(a2),d1		* (12)
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		adda.w		256*2*2(a2),a2		* (16)

		dbra		d6,1b

		move.w		d1,EFCT_AtoP_Y(a5)	* d1.w = PCM予測値
		move.l		a0,EFCT_PCM_ADR(a5)	* a0.l = ADPCMアドレス
		move.l		a2,EFCT_AtoP_X(a5)	* a2.l = ADPCM->PCM変換テーブルアドレス

		rts


AtoP_EFCT01_02:	sub.l		#MIX_SIZE/2,EFCT_PCM_LEN(a5)	* 1/2再生(7.8kHz)
		bgt		@f
		bsr		AtoP_EFCT_end

@@:		move.w		EFCT_AtoP_Y(a5),d1	* d1.w = PCM予測値
		movea.l		EFCT_PCM_ADR(a5),a0	* a0.l = ADPCMアドレス
		movea.l		EFCT_AtoP_X(a5),a2	* a2.l = ADPCM->PCM変換テーブルアドレス

		moveq.l		#MIX_SIZE/2-1,d6	* ADPCM -> PCM 変換

1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		256*2(a2),d1		* (12)
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		adda.w		256*2*2(a2),a2		* (16)

		dbra		d6,1b

		move.w		d1,EFCT_AtoP_Y(a5)	* d1.w = PCM予測値
		move.l		a0,EFCT_PCM_ADR(a5)	* a0.l = ADPCMアドレス
		move.l		a2,EFCT_AtoP_X(a5)	* a2.l = ADPCM->PCM変換テーブルアドレス

		rts

AtoP_EFCT02_03:	sub.l		#MIX_SIZE*2/3,EFCT_PCM_LEN(a5)	* 2/3再生(10.4kHz)
		bgt		@f
		bsr		AtoP_EFCT_end

@@:		move.w		EFCT_AtoP_Y(a5),d1	* d1.w = PCM予測値
		movea.l		EFCT_PCM_ADR(a5),a0	* a0.l = ADPCMアドレス
		movea.l		EFCT_AtoP_X(a5),a2	* a2.l = ADPCM->PCM変換テーブルアドレス

		moveq.l		#(MIX_SIZE*2)/3/8-1,d6	* ADPCM -> PCM 変換
1:
		REPT		8			* 8倍展開
		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		d1,(a1)+
		add.w		d1,(a1)+
		add.w		256*2(a2),d1		* (12)
		add.w		d1,(a1)+
		adda.w		256*2*2(a2),a2		* (16)
		ENDM
		dbra		d6,1b

		move.w		d1,EFCT_AtoP_Y(a5)	* d1.w = PCM予測値
		move.l		a0,EFCT_PCM_ADR(a5)	* a0.l = ADPCMアドレス
		move.l		a2,EFCT_AtoP_X(a5)	* a2.l = ADPCM->PCM変換テーブルアドレス

		rts


AtoP_EFCT01_01:	sub.l		#MIX_SIZE,EFCT_PCM_LEN(a5)	* 1/1 再生 (15.6kHz)
		bgt		@f
		bsr		AtoP_EFCT_end

@@:		move.w		EFCT_AtoP_Y(a5),d1	* d1.w = PCM予測値
		movea.l		EFCT_PCM_ADR(a5),a0	* a0.l = ADPCMアドレス
		movea.l		EFCT_AtoP_X(a5),a2	* a2.l = ADPCM->PCM変換テーブルアドレス

		moveq.l		#MIX_SIZE/8-1,d6	* ADPCM -> PCM 変換
1:
		REPT		8			* 8倍展開
		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		d1,(a1)+
		add.w		256*2(a2),d1		* (12)
		add.w		d1,(a1)+
		adda.w		256*2*2(a2),a2		* (16)
		ENDM
		dbra		d6,1b

		move.w		d1,EFCT_AtoP_Y(a5)	* d1.w = PCM予測値
		move.l		a0,EFCT_PCM_ADR(a5)	* a0.l = ADPCMアドレス
		move.l		a2,EFCT_AtoP_X(a5)	* a2.l = ADPCM->PCM変換テーブルアドレス

		rts

AtoP_EFCT04_03:	sub.l		#MIX_SIZE*4/3,EFCT_PCM_LEN(a5)	* 4/3再生(20.8kHz)
		bgt		@f
		bsr		AtoP_EFCT_end

@@:		move.w		EFCT_AtoP_Y(a5),d1	* d1.w = PCM予測値
		movea.l		EFCT_PCM_ADR(a5),a0	* a0.l = ADPCMアドレス
		movea.l		EFCT_AtoP_X(a5),a2	* a2.l = ADPCM->PCM変換テーブルアドレス

		moveq.l		#(MIX_SIZE*2)/3/8-1,d6	* ADPCM -> PCM 変換
1:
		REPT		8			* 8倍展開
		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		d1,(a1)+
		add.w		256*2(a2),d1		* (12)
		add.w		d1,(a1)+
		adda.w		256*2*2(a2),a2		* (16)

		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		d1,(a1)+
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		ENDM
		dbra		d6,1b

		move.w		d1,EFCT_AtoP_Y(a5)	* d1.w = PCM予測値
		move.l		a0,EFCT_PCM_ADR(a5)	* a0.l = ADPCMアドレス
		move.l		a2,EFCT_AtoP_X(a5)	* a2.l = ADPCM->PCM変換テーブルアドレス

		rts

AtoP_EFCT02_01:	sub.l		#MIX_SIZE*2,EFCT_PCM_LEN(a5)	* 2/1 再生
		bgt		@f
		bsr		AtoP_EFCT_end

@@:		move.w		EFCT_AtoP_Y(a5),d1	* d1.w = PCM予測値
		movea.l		EFCT_PCM_ADR(a5),a0	* a0.l = ADPCMアドレス
		movea.l		EFCT_AtoP_X(a5),a2	* a2.l = ADPCM->PCM変換テーブルアドレス

		moveq.l		#MIX_SIZE/4-1,d6	* ADPCM -> PCM 変換
1:
		REPT		8			* 8倍展開
		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		d1,(a1)+
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		ENDM
		dbra		d6,1b

		move.w		d1,EFCT_AtoP_Y(a5)	* d1.w = PCM予測値
		move.l		a0,EFCT_PCM_ADR(a5)	* a0.l = ADPCMアドレス
		move.l		a2,EFCT_AtoP_X(a5)	* a2.l = ADPCM->PCM変換テーブルアドレス

		rts

AtoP_EFCT08_03:	sub.l		#MIX_SIZE*8/3,EFCT_PCM_LEN(a5)	* 8/3再生
		bgt		@f
		bsr		AtoP_EFCT_end

@@:		move.w		EFCT_AtoP_Y(a5),d1	* d1.w = PCM予測値
		movea.l		EFCT_PCM_ADR(a5),a0	* a0.l = ADPCMアドレス
		movea.l		EFCT_AtoP_X(a5),a2	* a2.l = ADPCM->PCM変換テーブルアドレス

		moveq.l		#(MIX_SIZE*2)/3/8-1,d6	* ADPCM -> PCM 変換
1:
		REPT		8			* 8倍展開
		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		d1,(a1)+
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)

		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		256*2(a2),d1		* (12)
		add.w		d1,(a1)+
		adda.w		256*2*2(a2),a2		* (16)

		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)

		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		d1,(a1)+
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)

		ENDM
		dbra		d6,1b

		move.w		d1,EFCT_AtoP_Y(a5)	* d1.w = PCM予測値
		move.l		a0,EFCT_PCM_ADR(a5)	* a0.l = ADPCMアドレス
		move.l		a2,EFCT_AtoP_X(a5)	* a2.l = ADPCM->PCM変換テーブルアドレス

		rts

AtoP_EFCT04_01:	sub.l		#MIX_SIZE*4,EFCT_PCM_LEN(a5)	* 1/1 再生 (15.6kHz)
		bgt		@f
		bsr		AtoP_EFCT_end

@@:		move.w		EFCT_AtoP_Y(a5),d1	* d1.w = PCM予測値
		movea.l		EFCT_PCM_ADR(a5),a0	* a0.l = ADPCMアドレス
		movea.l		EFCT_AtoP_X(a5),a2	* a2.l = ADPCM->PCM変換テーブルアドレス

		moveq.l		#MIX_SIZE/4-1,d6	* ADPCM -> PCM 変換
1:
		REPT		8			* 8倍展開
		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		d1,(a1)+
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)

		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		ENDM
		dbra		d6,1b

		move.w		d1,EFCT_AtoP_Y(a5)	* d1.w = PCM予測値
		move.l		a0,EFCT_PCM_ADR(a5)	* a0.l = ADPCMアドレス
		move.l		a2,EFCT_AtoP_X(a5)	* a2.l = ADPCM->PCM変換テーブルアドレス

		rts


AtoP_EFCT_end:	move.b		EFCT_PLAY_MODE(a5),d0
		bne		@f
1:		clr.b		ADPCM_SYSWORK.w			* 通常再生
		clr.b		EFCT_PLAY_FLAG(a5)
		addq.l		#4,sp
		move.w		EFCT_AtoP_Y(a5),d0
		rts
@@:		cmpi.b		#$01,d0
		bne		@f
		subi.l		#1,EFCT_CTBL_N(a5)		* アレイチェーン
		beq		1b
		movea.l		EFCT_CTBL_ADR(a5),a0
		move.l		(a0)+,EFCT_PCM_ADR(a5)
		clr.w		EFCT_PCM_LEN(a5)
		move.w		(a0)+,EFCT_PCM_LEN+2(a5)
		move.l		a0,EFCT_CTBL_ADR(a5)
		move.l		#AtoP_tbl,EFCT_AtoP_X(a5)
		clr.w		EFCT_AtoP_Y(a5)
		rts

@@:		move.l		EFCT_CTBL_ADR(a5),d0		* リンクアレイチェーン
		beq		1b
		movea.l		d0,a0
		move.l		(a0)+,EFCT_PCM_ADR(a5)
		clr.w		EFCT_PCM_LEN(a5)
		move.w		(a0)+,EFCT_PCM_LEN+2(a5)
		move.l		(a0)+,EFCT_CTBL_ADR(a5)
		move.l		#AtoP_tbl,EFCT_AtoP_X(a5)
		clr.w		EFCT_AtoP_Y(a5)
		rts
