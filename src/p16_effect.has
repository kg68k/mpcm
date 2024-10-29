*=======================================================
*
*	ＩＯＣＳ各周波数16bitPCM変換
*
*=======================================================

PCM16_EFCT01_08:sub.l		#(MIX_SIZE*4)/8,EFCT_PCM_LEN(a5)	* 1/4再生(3.9kHz)
		bgt		@f
		bsr		PCM16_EFCT_end		* 軽さ重視です。すまん。

@@:		movea.l		EFCT_PCM_ADR(a5),a0	* a0.l = PCMアドレス
		moveq.l		#(MIX_SIZE*2)/8-1,d6	* 16bitPCM 変換
1:		move.w		(a0)+,d0
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		dbra		d6,1b

		move.l		a0,EFCT_PCM_ADR(a5)	* a0.l = PCMアドレス
		rts

PCM16_EFCT01_06:sub.l		#(MIX_SIZE*4)/6,EFCT_PCM_LEN(a5)	* 1/6再生
		bgt		@f
		bsr		PCM16_EFCT_end

@@:		movea.l		EFCT_PCM_ADR(a5),a0	* a0.l = PCMアドレス
		moveq.l		#(MIX_SIZE*2)/6-1,d6	* 16bitPCM 変換
1:		move.w		(a0)+,d0
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		dbra		d6,1b

		move.l		a0,EFCT_PCM_ADR(a5)	* a0.l = PCMアドレス
		rts

PCM16_EFCT01_04:sub.l		#(MIX_SIZE*4)/4,EFCT_PCM_LEN(a5)	* 1/4再生(3.9kHz)
		bgt		@f
		bsr		PCM16_EFCT_end		* 軽さ重視です。すまん。

@@:		movea.l		EFCT_PCM_ADR(a5),a0	* a0.l = PCMアドレス
		moveq.l		#(MIX_SIZE*2)/4-1,d6	* 16bitPCM 変換
1:		move.w		(a0)+,d0
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		dbra		d6,1b

		move.l		a0,EFCT_PCM_ADR(a5)	* a0.l = PCMアドレス
		rts

PCM16_EFCT01_03:sub.l		#(MIX_SIZE*4)/3,EFCT_PCM_LEN(a5)	* 1/3再生(5.2kHz)
		bgt		@f
		bsr		PCM16_EFCT_end

@@:		movea.l		EFCT_PCM_ADR(a5),a0	* a0.l = PCMアドレス
		moveq.l		#(MIX_SIZE*2)/3-1,d6	* 16bitPCM 変換
1:		move.w		(a0)+,d0
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		dbra		d6,1b

		move.l		a0,EFCT_PCM_ADR(a5)	* a0.l = PCMアドレス
		rts


PCM16_EFCT01_02:sub.l		#(MIX_SIZE*4)/2,EFCT_PCM_LEN(a5)	* 1/2再生(7.8kHz)
		bgt		@f
		bsr		PCM16_EFCT_end

@@:		movea.l		EFCT_PCM_ADR(a5),a0	* a0.l = PCMアドレス
		moveq.l		#MIX_SIZE/2-1,d6	* 16bitPCM 変換
1:		move.w		(a0)+,d0
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		dbra		d6,1b

		move.l		a0,EFCT_PCM_ADR(a5)	* a0.l = PCMアドレス
		rts

PCM16_EFCT02_03:sub.l		#(MIX_SIZE*4*2)/3,EFCT_PCM_LEN(a5)	* 2/3再生(10.4kHz)
		bgt		@f
		bsr		PCM16_EFCT_end

@@:		movea.l		EFCT_PCM_ADR(a5),a0	* a0.l = PCMアドレス
		moveq.l		#(MIX_SIZE*2*2)/3/8-1,d6
1:
		REPT		8
		move.w		(a0)+,d0
		add.w		d0,(a1)+
		add.w		d0,(a1)+
		move.w		(a0)+,d0
		add.w		d0,(a1)+
		ENDM
		dbra		d6,1b

		move.l		a0,EFCT_PCM_ADR(a5)	* a0.l = PCMアドレス
		rts


PCM16_EFCT01_01:sub.l		#MIX_SIZE*4,EFCT_PCM_LEN(a5)	* 1/1 再生 (15.6kHz)
		bgt		@f
		bsr		PCM16_EFCT_end

@@:		movea.l		EFCT_PCM_ADR(a5),a0	* a0.l = PCMアドレス
		moveq.l		#(MIX_SIZE*2)/8-1,d6
1:
		REPT		8
		move.w		(a0)+,d0
		add.w		d0,(a1)+
		ENDM
		dbra		d6,1b

		move.l		a0,EFCT_PCM_ADR(a5)	* a0.l = PCMアドレス
		rts

PCM16_EFCT04_03:sub.l		#(MIX_SIZE*4*4)/3,EFCT_PCM_LEN(a5)	* 4/3再生(20.8kHz)
		bgt		@f
		bsr		PCM16_EFCT_end

@@:		movea.l		EFCT_PCM_ADR(a5),a0	* a0.l = PCMアドレス
		moveq.l		#(MIX_SIZE*2*2)/3/8-1,d6
1:
		REPT		8
		move.w		(a0)+,d0
		add.w		d0,(a1)+
		move.w		(a0)+,d0
		add.w		d0,(a1)+

		move.w		(a0)+,d0
		add.w		d0,(a1)+
		addq.l		#2,a0
		ENDM
		dbra		d6,1b

		move.l		a0,EFCT_PCM_ADR(a5)	* a0.l = PCMアドレス
		rts


PCM16_EFCT02_01:sub.l		#MIX_SIZE*4*2,EFCT_PCM_LEN(a5)	* 2/1 再生 (31.2kHz)
		bgt		@f
		bsr		PCM16_EFCT_end

@@:		movea.l		EFCT_PCM_ADR(a5),a0	* a0.l = PCMアドレス
		moveq.l		#(MIX_SIZE*2)/8-1,d6
1:
		REPT		8
		move.w		(a0)+,d0
		add.w		d0,(a1)+
		addq.l		#2,a0
		ENDM
		dbra		d6,1b

		move.l		a0,EFCT_PCM_ADR(a5)	* a0.l = PCMアドレス
		rts

PCM16_EFCT08_03:sub.l		#(MIX_SIZE*8*4)/3,EFCT_PCM_LEN(a5)	* 8/3再生(20.8kHz)
		bgt		@f
		bsr		PCM16_EFCT_end

@@:		movea.l		EFCT_PCM_ADR(a5),a0	* a0.l = PCMアドレス
		moveq.l		#(MIX_SIZE*2*2)/3/8-1,d6
1:
		REPT		8
		move.w		(a0)+,d0
		add.w		d0,(a1)+
		addq.l		#4,a0

		move.w		(a0)+,d0
		add.w		d0,(a1)+
		addq.l		#4,a0

		move.w		(a0)+,d0
		add.w		d0,(a1)+
		addq.l		#2,a0
		ENDM
		dbra		d6,1b

		move.l		a0,EFCT_PCM_ADR(a5)	* a0.l = PCMアドレス
		rts


PCM16_EFCT04_01:sub.l		#MIX_SIZE*8*2,EFCT_PCM_LEN(a5)	* 4/1 再生 (31.2kHz)
		bgt		@f
		bsr		PCM16_EFCT_end

@@:		movea.l		EFCT_PCM_ADR(a5),a0	* a0.l = PCMアドレス
		moveq.l		#(MIX_SIZE*2)/8-1,d6
1:
		REPT		8
		move.w		(a0)+,d0
		add.w		d0,(a1)+
		addq.l		#6,a0
		ENDM
		dbra		d6,1b

		move.l		a0,EFCT_PCM_ADR(a5)	* a0.l = PCMアドレス
		rts


PCM16_EFCT_end:	move.b		EFCT_PLAY_MODE(a5),d0
		bne		@f
1:		clr.b		ADPCM_SYSWORK.w			* 通常再生
		clr.b		EFCT_PLAY_FLAG(a5)
		addq.l		#4,sp
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
		rts

@@:		move.l		EFCT_CTBL_ADR(a5),d0		* リンクアレイチェーン
		beq		1b
		movea.l		d0,a0
		move.l		(a0)+,EFCT_PCM_ADR(a5)
		clr.w		EFCT_PCM_LEN(a5)
		move.w		(a0)+,EFCT_PCM_LEN+2(a5)
		move.l		(a0)+,EFCT_CTBL_ADR(a5)
		rts
