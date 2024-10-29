*=======================================================
*
*	ＡＤＰＣＭ－＞ＰＣＭ 高音程変換
*
*=======================================================


* トラップ付き

AtoP_high_mac	macro		_vol

		local		EVEN1
		local		ODD1
		local		EVEN2
		local		ODD2

		local		EVENe1
		local		ODDe1
		local		EVENe2
		local		ODDe2

		local		EVENx1
		local		ODDx1
		local		EVENx2
		local		ODDx2

		local		EVENxe1
		local		ODDxe1
		local		EVENxe2
		local		ODDxe2

* 前に処理したADPCMが偶数番目の場合

		moveq.l		#MIX_SIZE-1-1,d7	* (作成16bitPCM個数/2)-1 回のループ

		move.l		CH_TPCNST(a5),d0
		add.l		a0,d0
		cmp.l		a3,d0
		bcs		1f

		tst.b		CH_ODDEVEN(a5)		* トラップ付変換
		bmi		ODD1
		bra		EVEN1

1:		tst.b		CH_ODDEVEN(a5)		* トラップ無し変換
		bmi		ODDx1
		bra		EVENx1


EVEN1:		moveq.l		#0,d6
		add.w		d3,d4			* PITCH_CTR += PITCH
		addx.w		d2,d6
		lsr.w		#1,d6
		bcs		2f

@@:		cmpa.l		a3,a0			* カウンタ>=2の偶数の場合
		bcs		1f
		jsr		(a4)			* トラップ処理
1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		bra		EVEN2			* 次も偶数

2:		beq		3f

@@:		cmpa.l		a3,a0			* カウンタ>=3の奇数の場合
		bcs		1f
		jsr		(a4)			* トラップ処理
1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		move.w		d1,d0
		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		bra		ODD2			* 次は奇数

3:
		move.w		d1,d0
		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		bra		ODD2			* 次は奇数


* 前に処理したADPCMが奇数番目の場合

ODD1:		moveq.l		#0,d6
		add.w		d3,d4			* PITCH_CTR += PITCH
		addx.w		d2,d6
		lsr.w		#1,d6
		bcs		2f

@@:		cmpa.l		a3,a0			* カウンタ>=2の偶数の場合
		bcs		1f
		jsr		(a4)			* トラップ処理
1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		move.w		d1,d0
		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		bra		ODD2			* 次も奇数


2:		beq		3f

		addq.w		#1,d6			* 前のが奇数番目のADPCMだから1足す
@@:		cmpa.l		a3,a0			* カウンタ>=3の奇数の場合
		bcs		1f
		jsr		(a4)			* トラップ処理
1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		bra		EVEN2			* 次は偶数

3:		cmpa.l		a3,a0			* カウンタが1の場合
		bcs		1f
		jsr		(a4)			* トラップ処理
1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)

		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
*		bra		EVEN2			* 次は偶数


EVEN2:		moveq.l		#0,d6
		add.w		d3,d4			* PITCH_CTR += PITCH
		addx.w		d2,d6
		lsr.w		#1,d6
		bcs		2f

@@:		cmpa.l		a3,a0			* カウンタ>=2の偶数の場合
		bcs		1f
		jsr		(a4)			* トラップ処理
1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		dbra		d7,EVEN1		* 次も偶数
		bra		EVENe1

2:		beq		3f

@@:		cmpa.l		a3,a0			* カウンタ>=3の奇数の場合
		bcs		1f
		jsr		(a4)			* トラップ処理
1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		move.w		d1,d0
		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		dbra		d7,ODD1			* 次は奇数
		bra		ODDe1

3:
		move.w		d1,d0
		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		dbra		d7,ODD1			* 次は奇数
		bra		ODDe1


* 前に処理したADPCMが奇数番目の場合

ODD2:		moveq.l		#0,d6
		add.w		d3,d4			* PITCH_CTR += PITCH
		addx.w		d2,d6
		lsr.w		#1,d6
		bcs		2f

@@:		cmpa.l		a3,a0			* カウンタ>=2の偶数の場合
		bcs		1f
		jsr		(a4)			* トラップ処理
1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		move.w		d1,d0
		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		dbra		d7,ODD1			* 次も奇数
		bra		ODDe1

2:		beq		3f

		addq.w		#1,d6			* 前のが奇数番目のADPCMだから1足す
@@:		cmpa.l		a3,a0			* カウンタ>=3の奇数の場合
		bcs		1f
		jsr		(a4)			* トラップ処理
1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		dbra		d7,EVEN1		* 次は偶数
		bra		EVENe1

3:		cmpa.l		a3,a0			* カウンタが1の場合
		bcs		1f
		jsr		(a4)			* トラップ処理
1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)

		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		dbra		d7,EVEN1			* 次は偶数
*		bra		EVENe1

*最後の2PCM分の展開
* 前に処理したADPCMが偶数番目の場合

EVENe1:		moveq.l		#0,d6
		add.w		d3,d4			* PITCH_CTR += PITCH
		addx.w		d2,d6
		lsr.w		#1,d6
		bcs		2f

@@:		cmpa.l		a3,a0			* カウンタ>=2の偶数の場合
		bcs		1f
		jsr		(a4)			* トラップ処理
1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		bra		EVENe2			* 次も偶数

2:		beq		3f

@@:		cmpa.l		a3,a0			* カウンタ>=3の奇数の場合
		bcs		1f
		jsr		(a4)			* トラップ処理
1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		move.w		d1,d0
		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		bra		ODDe2			* 次は奇数

3:
		move.w		d1,d0
		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		bra		ODDe2			* 次は奇数


* 前に処理したADPCMが奇数番目の場合

ODDe1:		moveq.l		#0,d6
		add.w		d3,d4			* PITCH_CTR += PITCH
		addx.w		d2,d6
		lsr.w		#1,d6
		bcs		2f

@@:		cmpa.l		a3,a0			* カウンタ>=2の偶数の場合
		bcs		1f
		jsr		(a4)			* トラップ処理
1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		move.w		d1,d0
		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		bra		ODDe2			* 次も奇数


2:		beq		3f

		addq.w		#1,d6			* 前のが奇数番目のADPCMだから1足す
@@:		cmpa.l		a3,a0			* カウンタ>=3の奇数の場合
		bcs		1f
		jsr		(a4)			* トラップ処理
1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		bra		EVENe2			* 次は偶数

3:		cmpa.l		a3,a0			* カウンタが1の場合
		bcs		1f
		jsr		(a4)			* トラップ処理
1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)

		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
*		bra		EVENe2			* 次は偶数


EVENe2:		moveq.l		#0,d6
		add.w		d3,d4			* PITCH_CTR += PITCH
		addx.w		d2,d6
		lsr.w		#1,d6
		bcs		2f

@@:		cmpa.l		a3,a0			* カウンタ>=2の偶数の場合
		bcs		1f
		jsr		(a4)			* トラップ処理
1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		move.w		d0,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d0.w
		move.w		d1,CH_AtoP_Y(a5)	* PCM予測値 = d1.w
		move.b		#1,CH_ODDEVEN(a5)	* ODD/EVEN FLAG = EVEN
		move.w		d4,CH_PITCH_CTR(a5)	* ピッチカウンタの下位16bit = d4.w
		move.l		a0,CH_PCM_ADR(a5)	* ADPCMアドレス = a0.l
		move.l		a2,CH_AtoP_X(a5)	* ADPCM->PCM変換テーブルアドレス = a2.l
		VOLUME		_vol,d0,d6
		move.w		d0,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d0,(a1)+
		rts

2:		beq		3f

@@:		cmpa.l		a3,a0			* カウンタ>=3の奇数の場合
		bcs		1f
		jsr		(a4)			* トラップ処理
1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		move.w		d1,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d1.w
		move.w		d1,CH_AtoP_Y(a5)	* PCM予測値 = d1.w
		st.b		CH_ODDEVEN(a5)		* ODD/EVEN FLAG = ODD
		move.w		d4,CH_PITCH_CTR(a5)	* ピッチカウンタの下位16bit = d4.w
		move.l		a0,CH_PCM_ADR(a5)	* ADPCMアドレス = a0.l
		move.l		a2,CH_AtoP_X(a5)	* ADPCM->PCM変換テーブルアドレス = a2.l
		VOLUME		_vol,d1,d6
		move.w		d1,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d1,(a1)+
		rts

3:		move.w		d1,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d1.w
		move.w		d1,CH_AtoP_Y(a5)	* PCM予測値 = d1.w
		st.b		CH_ODDEVEN(a5)		* ODD/EVEN FLAG = ODD
		move.w		d4,CH_PITCH_CTR(a5)	* ピッチカウンタの下位16bit = d4.w
		move.l		a0,CH_PCM_ADR(a5)	* ADPCMアドレス = a0.l
		move.l		a2,CH_AtoP_X(a5)	* ADPCM->PCM変換テーブルアドレス = a2.l
		VOLUME		_vol,d1,d6
		move.w		d1,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d1,(a1)+
		rts


* 前に処理したADPCMが奇数番目の場合

ODDe2:		moveq.l		#0,d6
		add.w		d3,d4			* PITCH_CTR += PITCH
		addx.w		d2,d6
		lsr.w		#1,d6
		bcs		2f

@@:		cmpa.l		a3,a0			* カウンタ>=2の偶数の場合
		bcs		1f
		jsr		(a4)			* トラップ処理
1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		move.w		d1,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d1.w
		move.w		d1,CH_AtoP_Y(a5)	* PCM予測値 = d1.w
		st.b		CH_ODDEVEN(a5)		* ODD/EVEN FLAG = ODD
		move.w		d4,CH_PITCH_CTR(a5)	* ピッチカウンタの下位16bit = d4.w
		move.l		a0,CH_PCM_ADR(a5)	* ADPCMアドレス = a0.l
		move.l		a2,CH_AtoP_X(a5)	* ADPCM->PCM変換テーブルアドレス = a2.l
		VOLUME		_vol,d1,d6
		move.w		d1,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d1,(a1)+
		rts

2:		beq		3f

		addq.w		#1,d6			* 前のが奇数番目のADPCMだから1足す
@@:		cmpa.l		a3,a0			* カウンタ>=3の奇数の場合
		bcs		1f
		jsr		(a4)			* トラップ処理
1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		move.w		d0,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d0.w
		move.w		d1,CH_AtoP_Y(a5)	* PCM予測値 = d1.w
		move.b		#1,CH_ODDEVEN(a5)	* ODD/EVEN FLAG = EVEN
		move.w		d4,CH_PITCH_CTR(a5)	* ピッチカウンタの下位16bit = d4.w
		move.l		a0,CH_PCM_ADR(a5)	* ADPCMアドレス = a0.l
		move.l		a2,CH_AtoP_X(a5)	* ADPCM->PCM変換テーブルアドレス = a2.l
		VOLUME		_vol,d0,d6
		move.w		d0,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d0,(a1)+
		rts

3:		cmpa.l		a3,a0			* カウンタが1の場合
		bcs		1f
		jsr		(a4)			* トラップ処理
1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)

		move.w		d0,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d0.w
		move.w		d1,CH_AtoP_Y(a5)	* PCM予測値 = d1.w
		move.b		#1,CH_ODDEVEN(a5)	* ODD/EVEN FLAG = EVEN
		move.w		d4,CH_PITCH_CTR(a5)	* ピッチカウンタの下位16bit = d4.w
		move.l		a0,CH_PCM_ADR(a5)	* ADPCMアドレス = a0.l
		move.l		a2,CH_AtoP_X(a5)	* ADPCM->PCM変換テーブルアドレス = a2.l
		VOLUME		_vol,d0,d7
		move.w		d0,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d0,(a1)+
		rts



* トラップ無し
* 前に処理したADPCMが偶数番目の場合


EVENx1:		moveq.l		#0,d6
		add.w		d3,d4			* PITCH_CTR += PITCH
		addx.w		d2,d6
		lsr.w		#1,d6
		bcs		2f

@@:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		bra		EVENx2			* 次も偶数

2:		beq		3f

@@:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		move.w		d1,d0
		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		bra		ODDx2			* 次は奇数

3:		move.w		d1,d0
		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		bra		ODDx2			* 次は奇数


* 前に処理したADPCMが奇数番目の場合

ODDx1:		moveq.l		#0,d6
		add.w		d3,d4			* PITCH_CTR += PITCH
		addx.w		d2,d6
		lsr.w		#1,d6
		bcs		2f

@@:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		move.w		d1,d0
		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		bra		ODDx2			* 次も奇数


2:		beq		3f

		addq.w		#1,d6			* 前のが奇数番目のADPCMだから1足す
@@:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		bra		EVENx2			* 次は偶数

3:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)

		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
*		bra		EVENx2			* 次は偶数


EVENx2:		moveq.l		#0,d6
		add.w		d3,d4			* PITCH_CTR += PITCH
		addx.w		d2,d6
		lsr.w		#1,d6
		bcs		2f

@@:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		dbra		d7,EVENx1		* 次も偶数
		bra		EVENxe1

2:		beq		3f

@@:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		move.w		d1,d0
		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		dbra		d7,ODDx1		* 次は奇数
		bra		ODDxe1

3:		move.w		d1,d0
		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		dbra		d7,ODDx1		* 次は奇数
		bra		ODDxe1


* 前に処理したADPCMが奇数番目の場合

ODDx2:		moveq.l		#0,d6
		add.w		d3,d4			* PITCH_CTR += PITCH
		addx.w		d2,d6
		lsr.w		#1,d6
		bcs		2f

@@:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		move.w		d1,d0
		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		dbra		d7,ODDx1		* 次も奇数
		bra		ODDxe1

2:		beq		3f

		addq.w		#1,d6			* 前のが奇数番目のADPCMだから1足す
@@:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		dbra		d7,EVENx1		* 次は偶数
		bra		EVENxe1

3:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)

		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		dbra		d7,EVENx1		* 次は偶数
		bra		ODDxe1

EVENxe1:	moveq.l		#0,d6
		add.w		d3,d4			* PITCH_CTR += PITCH
		addx.w		d2,d6
		lsr.w		#1,d6
		bcs		2f

@@:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		bra		EVENxe2			* 次も偶数

2:		beq		3f

@@:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		move.w		d1,d0
		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		bra		ODDxe2			* 次は奇数

3:		move.w		d1,d0
		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		bra		ODDxe2			* 次は奇数


* 前に処理したADPCMが奇数番目の場合

ODDxe1:		moveq.l		#0,d6
		add.w		d3,d4			* PITCH_CTR += PITCH
		addx.w		d2,d6
		lsr.w		#1,d6
		bcs		2f

@@:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		move.w		d1,d0
		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		bra		ODDxe2			* 次も奇数


2:		beq		3f

		addq.w		#1,d6			* 前のが奇数番目のADPCMだから1足す
@@:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
		bra		EVENxe2			* 次は偶数

3:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)

		VOLUME		_vol,d0,d6
		add.w		d0,(a1)+
*		bra		EVENxe2			* 次は偶数


EVENxe2:	moveq.l		#0,d6
		add.w		d3,d4			* PITCH_CTR += PITCH
		addx.w		d2,d6
		lsr.w		#1,d6
		bcs		2f

@@:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		move.w		d0,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d0.w
		move.w		d1,CH_AtoP_Y(a5)	* PCM予測値 = d1.w
		move.b		#1,CH_ODDEVEN(a5)	* ODD/EVEN FLAG = EVEN
		move.w		d4,CH_PITCH_CTR(a5)	* ピッチカウンタの下位16bit = d4.w
		move.l		a0,CH_PCM_ADR(a5)	* ADPCMアドレス = a0.l
		move.l		a2,CH_AtoP_X(a5)	* ADPCM->PCM変換テーブルアドレス = a2.l
		VOLUME		_vol,d0,d6
		move.w		d0,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d0,(a1)+
		rts

2:		beq		3f

@@:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		move.w		d1,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d1.w
		move.w		d1,CH_AtoP_Y(a5)	* PCM予測値 = d1.w
		st.b		CH_ODDEVEN(a5)		* ODD/EVEN FLAG = ODD
		move.w		d4,CH_PITCH_CTR(a5)	* ピッチカウンタの下位16bit = d4.w
		move.l		a0,CH_PCM_ADR(a5)	* ADPCMアドレス = a0.l
		move.l		a2,CH_AtoP_X(a5)	* ADPCM->PCM変換テーブルアドレス = a2.l
		VOLUME		_vol,d1,d6
		move.w		d1,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d1,(a1)+
		rts

3:		move.w		d1,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d1.w
		move.w		d1,CH_AtoP_Y(a5)	* PCM予測値 = d1.w
		st.b		CH_ODDEVEN(a5)		* ODD/EVEN FLAG = ODD
		move.w		d4,CH_PITCH_CTR(a5)	* ピッチカウンタの下位16bit = d4.w
		move.l		a0,CH_PCM_ADR(a5)	* ADPCMアドレス = a0.l
		move.l		a2,CH_AtoP_X(a5)	* ADPCM->PCM変換テーブルアドレス = a2.l
		VOLUME		_vol,d1,d6
		move.w		d1,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d1,(a1)+
		rts


* 前に処理したADPCMが奇数番目の場合

ODDxe2:		moveq.l		#0,d6
		add.w		d3,d4			* PITCH_CTR += PITCH
		addx.w		d2,d6
		lsr.w		#1,d6
		bcs		2f

@@:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		move.w		d1,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d1.w
		move.w		d1,CH_AtoP_Y(a5)	* PCM予測値 = d1.w
		st.b		CH_ODDEVEN(a5)		* ODD/EVEN FLAG = ODD
		move.w		d4,CH_PITCH_CTR(a5)	* ピッチカウンタの下位16bit = d4.w
		move.l		a0,CH_PCM_ADR(a5)	* ADPCMアドレス = a0.l
		move.l		a2,CH_AtoP_X(a5)	* ADPCM->PCM変換テーブルアドレス = a2.l
		VOLUME		_vol,d1,d6
		move.w		d1,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d1,(a1)+
		rts

2:		beq		3f

		addq.w		#1,d6			* 前のが奇数番目のADPCMだから1足す
@@:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)
		subq.w		#1,d6
		bne		@b

		move.w		d0,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d0.w
		move.w		d1,CH_AtoP_Y(a5)	* PCM予測値 = d1.w
		move.b		#1,CH_ODDEVEN(a5)	* ODD/EVEN FLAG = EVEN
		move.w		d4,CH_PITCH_CTR(a5)	* ピッチカウンタの下位16bit = d4.w
		move.l		a0,CH_PCM_ADR(a5)	* ADPCMアドレス = a0.l
		move.l		a2,CH_AtoP_X(a5)	* ADPCM->PCM変換テーブルアドレス = a2.l
		VOLUME		_vol,d0,d6
		move.w		d0,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d0,(a1)+
		rts

3:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,d0			* (4)
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)

		move.w		d0,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d0.w
		move.w		d1,CH_AtoP_Y(a5)	* PCM予測値 = d1.w
		move.b		#1,CH_ODDEVEN(a5)	* ODD/EVEN FLAG = EVEN
		move.w		d4,CH_PITCH_CTR(a5)	* ピッチカウンタの下位16bit = d4.w
		move.l		a0,CH_PCM_ADR(a5)	* ADPCMアドレス = a0.l
		move.l		a2,CH_AtoP_X(a5)	* ADPCM->PCM変換テーブルアドレス = a2.l
		VOLUME		_vol,d0,d6
		move.w		d0,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d0,(a1)+
		rts

		endm


*=======================================================

AtoP_high:
		move.w		CH_PITCH(a5),d2		* 音程ピッチ上位16bit
		move.w		CH_PITCH+2(a5),d3	* 音程ピッチ下位16bit
		move.w		CH_VOL(a5),d5		* d5.w = ADPCM VOLUME

		tst.b		CH_KEY_STAT(a5)		* keyon=$01 keyoff=$80 non=$00
		bmi		AtoP_high_keyoff
		bne		AtoP_high_keyon

*		通常の処理
		move.w		CH_AtoP_Y(a5),d1	* d1.w = PCM予測値
		move.w		CH_PITCH_CTR(a5),d4	* d4.w = 音程カウンタ下位16bit
		moveq.l		#0,d6			* d6.w = 音程カウンタ上位16bit
		movea.l		CH_PCM_ADR(a5),a0	* a0.l = ADPCMアドレス
		movea.l		CH_AtoP_X(a5),a2	* a2.l = ADPCM->PCM変換テーブルアドレス
		movea.l		CH_TRAP_ADR(a5),a3	* a3.l = 変換中のトラップアドレス
		movea.l		CH_TRAP_ROUTINE(a5),a4	* a4.l = トラップ時の処理ルーチン

		movea.l		CH_JMP_ADR2(a5),a6
		jmp		(a6)

*		キーオンの処理
AtoP_high_keyon:
		clr.b		CH_KEY_STAT(a5)		* KEY 状態リセット

		moveq.l		#0,d1			* d1.w = PCM予測値
		st.b		CH_ODDEVEN(a5)		* ODD/EVEN FLAG リセット
		moveq.l		#0,d4			* d4.w = 音程カウンタ下位16bit
		moveq.l		#0,d6			* d6.w = 音程カウンタ上位16bit
		movea.l		CH_TOP_ADR(a5),a0	* a0.l = ADPCM先頭アドレス
		movea.l		#AtoP_tbl,a2		* a2.l = 変換テーブル

		move.l		CH_LPTIME(a5),d7	* ループ処理をするか
		moveq.l		#1,d0
		cmp.l		d0,d7			* cmpi.l より4clk速い
		beq		1f
		move.l		d7,CH_LPTIME_CTR(a5)	* ループ回数カウンタ初期化
		movea.l		CH_LPSTART_ADR(a5),a3	* a3.l = ループスタートアドレス
		lea.l		AtoP_LOOP,a4		* a4.l = ループスタート処理アドレス
		move.l		a3,CH_TRAP_ADR(a5)
		move.l		a4,CH_TRAP_ROUTINE(a5)	* トラップ情報ををワークに保存

		movea.l		CH_JMP_ADR2(a5),a6
		jmp		(a6)

1:		movea.l		CH_END_ADR(a5),a3	* a3.l = ADPCMデータ終了アドレス
		lea.l		AtoP_END,a4		* a4.l = データ終了処理アドレス
		move.l		a3,CH_TRAP_ADR(a5)
		move.l		a4,CH_TRAP_ROUTINE(a5)	* トラップ情報をワークに保存

		movea.l		CH_JMP_ADR2(a5),a6
		jmp		(a6)

*		キーオフの処理
AtoP_high_keyoff:
		clr.b		CH_KEY_STAT(a5)		* KEY 状態リセット
		clr.b		CH_PLAY_FLAG(a5)	* 演奏終了
		jmp		make_keyoff_PCM		* 消音PCM展開

*=======================================================

AtoP_high_v00:	AtoP_high_mac	0
AtoP_high_v01:	AtoP_high_mac	1
AtoP_high_v02:	AtoP_high_mac	2
AtoP_high_v03:	AtoP_high_mac	3
AtoP_high_v04:	AtoP_high_mac	4
AtoP_high_v05:	AtoP_high_mac	5
AtoP_high_v06:	AtoP_high_mac	6
AtoP_high_v07:	AtoP_high_mac	7
AtoP_high_v08:	AtoP_high_mac	8
AtoP_high_v09:	AtoP_high_mac	9
AtoP_high_v10:	AtoP_high_mac	10
AtoP_high_v11:	AtoP_high_mac	11
AtoP_high_v12:	AtoP_high_mac	12
AtoP_high_v13:	AtoP_high_mac	13
AtoP_high_v14:	AtoP_high_mac	14
AtoP_high_v15:	AtoP_high_mac	15
AtoP_high_vnn:	AtoP_high_mac	'n'
AtoP_high_non:	AtoP_high_mac	'x'
