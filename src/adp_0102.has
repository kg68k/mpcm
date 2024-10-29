*=======================================================
*
*	ＡＤＰＣＭ－＞ＰＣＭ 7.8kHz変換
*
*=======================================================

AtoP7n		macro		_X,_vol

		local		next

	.if	_X
		cmpa.l		a3,a0			* トラップにかかった？
		bcs		next
		jsr		(a4)			* トラップ処理
	.endif
next:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
	.if	_vol=8
		add.w		d1,(a1)+
		add.w		d1,(a1)+
	.else
		move.w		d1,d0			* (4)
		VOLUME		_vol,d0,d2
		add.w		d0,(a1)+
		add.w		d0,(a1)+
	.endif
		add.w		256*2(a2),d1		* (12)
	.if	_vol=8
		add.w		d1,(a1)+
		add.w		d1,(a1)+
	.else
		move.w		d1,d0			* (4)
		VOLUME		_vol,d0,d2
		add.w		d0,(a1)+
		add.w		d0,(a1)+
	.endif
		adda.w		256*2*2(a2),a2		* (16)

		endm

*=======================================================

AtoP_0102_mac	macro		_vol

		local		ADPCM_odd

		tst.b		CH_ODDEVEN(a5)		* ODD/EVEN FLAG	のチェック
		bpl		ADPCM_odd		* 変換が1ADPCMずれる場合

*		前が奇数番目のADPCMを処理していた場合
@@:		moveq.l		#(MIX_SIZE/2)-1,d2	* (4) 今回の処理中になんらかの
		add.l		a0,d2			* (8) トラップが発生するか調べる
		cmp.l		a3,d2			* (6)
		bcs		@f			* (10)

*		トラップ判定あり
		moveq.l		#MIX_SIZE/2-1,d6
1:		AtoP7n		1,_vol
		dbra		d6,1b
		move.w		d1,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d1.w
	.if	_vol=8
		move.w		d1,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
	.else
		move.w		d0,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
	.endif
		move.w		d1,CH_AtoP_Y(a5)	* PCM予測値 = d1.w
		move.l		a0,CH_PCM_ADR(a5)	* ADPCMアドレス = a0.l
		move.l		a2,CH_AtoP_X(a5)	* ADPCM->PCM変換テーブルアドレス = a2.l
		rts

*		トラップ判定無し
@@:		moveq.l		#MIX_SIZE/2-1,d6	* ADPCM -> PCM 変換
1:		AtoP7n		0,_vol
		dbra		d6,1b
		move.w		d1,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d1.w
	.if	_vol=8
		move.w		d1,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
	.else
		move.w		d0,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
	.endif
		move.w		d1,CH_AtoP_Y(a5)	* PCM予測値 = d1.w
		move.l		a0,CH_PCM_ADR(a5)	* ADPCMアドレス = a0.l
		move.l		a2,CH_AtoP_X(a5)	* ADPCM->PCM変換テーブルアドレス = a2.l
		rts

*		前が偶数番目のADPCMを処理していた場合
ADPCM_odd:	moveq.l		#(MIX_SIZE/2),d2	* (4) 今回の処理中になんらかの
		add.l		a0,d2			* (8) トラップが発生するか調べる
		cmp.l		a3,d2			* (6)
		bcs		@f			* (10)

*		トラップ判定あり
	.if	_vol=8
		add.w		d1,(a1)+
		add.w		d1,(a1)+
	.else
		move.w		d1,d0
		VOLUME		_vol,d0,d2
		add.w		d0,(a1)+
		add.w		d0,(a1)+
	.endif
		moveq.l		#MIX_SIZE/2-1-1,d6	* ADPCM -> PCM 変換
1:		AtoP7n		1,_vol
		dbra		d6,1b
							* ラストの1回
		cmpa.l		a3,a0			* トラップにかかった？
		bcs		1f
		jsr		(a4)			* トラップ処理
1:		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d1.w
	.if	_vol=8
		move.w		d1,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d1,(a1)+
		add.w		d1,(a1)+
	.else
		move.w		d1,d0			* (4)
		VOLUME		_vol,d0,d2
		move.w		d0,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d0,(a1)+
		add.w		d0,(a1)+
	.endif
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)

		move.w		d1,CH_AtoP_Y(a5)	* PCM予測値 = d1.w
		move.l		a0,CH_PCM_ADR(a5)	* ADPCMアドレス = a0.l
		move.l		a2,CH_AtoP_X(a5)	* ADPCM->PCM変換テーブルアドレス = a2.l
		rts

*		トラップ判定無し
@@:
	.if	_vol=8
		add.w		d1,(a1)+
		add.w		d1,(a1)+
	.else
		move.w		d1,d0
		VOLUME		_vol,d0,d2
		add.w		d0,(a1)+
		add.w		d0,(a1)+
	.endif
		moveq.l		#MIX_SIZE/2-1-1,d6	* ADPCM -> PCM 変換
1:		AtoP7n		0,_vol
		dbra		d6,1b
							* ラストの1回
		moveq.l		#0,d0			* (4)
		move.b		(a0)+,d0		* (8)
		add.w		d0,d0			* (4)
		adda.w		d0,a2			* (8)
		add.w		(a2),d1			* (8)
		move.w		d1,CH_LAST_PCM(a5)	* 前回変換終了時のPCM値 = d1.w
	.if	_vol=8
		move.w		d1,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d1,(a1)+
		add.w		d1,(a1)+
	.else
		move.w		d1,d0			* (4)
		VOLUME		_vol,d0,d2
		move.w		d0,CH_LAST_VPCM(a5)	* 最後のPCM値(音量変換後)
		add.w		d0,(a1)+
		add.w		d0,(a1)+
	.endif
		add.w		256*2(a2),d1		* (12)
		adda.w		256*2*2(a2),a2		* (16)

		move.w		d1,CH_AtoP_Y(a5)	* PCM予測値 = d1.w
		move.l		a0,CH_PCM_ADR(a5)	* ADPCMアドレス = a0.l
		move.l		a2,CH_AtoP_X(a5)	* ADPCM->PCM変換テーブルアドレス = a2.l
		rts

		endm

*=======================================================

AtoP_0102_v00:	AtoP_0102_mac	0
AtoP_0102_v01:	AtoP_0102_mac	1
AtoP_0102_v02:	AtoP_0102_mac	2
AtoP_0102_v03:	AtoP_0102_mac	3
AtoP_0102_v04:	AtoP_0102_mac	4
AtoP_0102_v05:	AtoP_0102_mac	5
AtoP_0102_v06:	AtoP_0102_mac	6
AtoP_0102_v07:	AtoP_0102_mac	7
AtoP_0102_v08:	AtoP_0102_mac	8
AtoP_0102_v09:	AtoP_0102_mac	9
AtoP_0102_v10:	AtoP_0102_mac	10
AtoP_0102_v11:	AtoP_0102_mac	11
AtoP_0102_v12:	AtoP_0102_mac	12
AtoP_0102_v13:	AtoP_0102_mac	13
AtoP_0102_v14:	AtoP_0102_mac	14
AtoP_0102_v15:	AtoP_0102_mac	15
AtoP_0102_vnn:	AtoP_0102_mac	'n'
AtoP_0102_non:	AtoP_0102_mac	'x'

