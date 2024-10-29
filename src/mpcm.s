*///////////////////////////////////////////////////////////////
*
*	Modulatable (ad)PCM driver MPCM.x version 0.45
*
*		重い、重いぜー
*
*///////////////////////////////////////////////////////////////


		.include	doscall.mac
		.include	iocscall.mac

		.include	mpcmcall.mac
		.include	mpcm_prg.mac

*---------------------------------------------------------------
*　　　　　　　　　　定数定義
*---------------------------------------------------------------

TAB		equ		$09
CR		equ		$0d
LF		equ		$0a
EOF		equ		$1a

DMA0		equ		$00e84000	* DMAチャンネル#0
DMA1		equ		$00e84040	* DMAチャンネル#1
DMA2		equ		$00e84080	* DMAチャンネル#2
DMA3		equ		$00e840c0	* DMAチャンネル#3
CSR		equ		$00
CER		equ		$01
DCR		equ		$04
OCR		equ		$05
SCR		equ		$06
DCCR		equ		$07
MTC		equ		$0a
MAR		equ		$0c
DAR		equ		$14
BTC		equ		$1a
BAR		equ		$1c
NIV		equ		$25
EIV		equ		$27
MFC		equ		$29
CPR		equ		$2d
DFC		equ		$31
BFC		equ		$39
GCR		equ		$3f

MFP		equ		$00e88000	* MFPアドレス
SYSTEMP		equ		$00e8e000	* システムポートアドレス
OPM		equ		$00e90000	* OPMアドレス
ADPCM		equ		$00e92000	* ADPCMアドレス
PPI		equ		$00e9a004	* PPI(i8255)ポートC
SPRITEC		equ		$00eb0000	* スプライトコントローラアドレス

TEXT_RAM	equ		$00e00000	* テキストRAM
G_RAM		equ		$00c00000	* グラフィックRAM
TEXT_PALET	equ		$00e82200	* テキストパレット
G_PALET		equ		$00e82000	* グラフィックパレット
SP_PALET	equ		$00e82200	* スプライトパレット(=TEXT_PALET)

ADPCM_SYSWORK	equ		$0c32		* IOCS用の動作状態ワーク(_ADPCMSNSで参照)

MIX_SIZE	equ		48		* 1回の割り込みで処理するADPCMのバイト数
CH_MAX		equ		16		* 演奏用最大発音数
CH_WORK_SIZE	equ		128		* 各PCMチャンネルのワークサイズ
EFCT_MAX	equ		8		* 効果音最大発音数
EFCT_WORK_SIZE	equ		64		* 各PCMチャンネルのワークサイズ

		.offset		0		* 音楽専用チャンネルのワーク

CH_JMP_ADR:	.ds.l		1		* (.l) PCMの種類による処理先アドレス
CH_JMP_ADR2:	.ds.l		1		* (.l) 音量による処理先アドレス
CH_TOP_ADR:	.ds.l		1		* (.l) PCMの先頭アドレス
CH_END_ADR:	.ds.l		1		* (.l) PCMの最終アドレス
CH_LPSTART_ADR:	.ds.l		1		* (.l) ループの先頭PCMアドレス
CH_LPEND_ADR:	.ds.l		1		* (.l) ループの終端PCMアドレス
CH_LPTIME:	.ds.l		1		* (.l) ループの回数
CH_LPTIME_CTR:	.ds.l		1		* (.l) ループの回数ワーク
CH_PCM_ADR:	.ds.l		1		* (.l) 現在処理中のPCMアドレス
CH_LOOP_X:	.ds.l		1		* (.l) ループ時のADPCM->PCM変換テーブルアドレス
CH_LOOP_Y:	.ds.w		1		* (.w) ループ時点ADPCM->PCM変換の基本PCMデータ
CH_LAST_PCM:	.ds.w		1		* (.w) 前回処理終了時のPCM値
CH_PITCH_CADR:	.ds.l		1		* (.l) 周波数に応じた音程変換ルーチンアドレス
CH_ORG_PITCH:	.ds.l		1		* (.l) CH_USER_NOTE/CH_ORG_NOTEから算出した音程
CH_PITCH:	.ds.l		1		* (.l) 周波数に応じて変換された音程
CH_PITCH_CTR:	.ds.w		1		* (.w) 前回割り込み終了時の音程カウンタ下位
CH_PAN:		.ds.w		1		* (.w) PCMのPAN(0-127)
CH_TRAP_ADR:	.ds.l		1		* (.l) 変換がこのアドレスに及ぶとジャンプする
CH_TRAP_ROUTINE:.ds.l		1		* (.l) そのジャンプ先の処理アドレス
CH_CHANNEL_MASK:.ds.l		1		* (.l) 各チャンネルに対応したビットマスク
CH_TPCNST_CADR:	.ds.l		1		* (.l) PCMアドレス増分計算ルーチンアドレス
CH_TPCNST:	.ds.l		1		* (.l) １回の割り込みでのPCMアドレス増分
CH_AtoP_X:	.ds.l		1		* (.l) 処理中のADPCM->PCM変換テーブルアドレス
CH_AtoP_Y:	.ds.w		1		* (.w) 処理中のADPCM->PCM変換基本PCMデータ
CH_ORG_NOTE:	.ds.w		1		* (.w) PCMデータの原音程
CH_USER_NOTE:	.ds.w		1		* (.w) ユーザ指定の音階(発音する音階)
CH_USER_VOL:	.ds.w		1		* (.w) ユーザ指定の音量($0000～$0040～$007f)
CH_VOL:		.ds.w		1		* (.w) 音量($0000～$0040～$007f)
CH_VOL_OFFS:	.ds.w		1		* (.w) 変換ルーチンアドレステーブルのオフセット
CH_CNVADR_BASE:	.ds.l		1		* (.w) 変換ルーチンアドレステーブルのベースアドレス
CH_LAST_VPCM:	.ds.w		1		* (.w) 音量変換後の最後の16bitPCM
CH_ODDEVEN:	.ds.b		1		* (.b) CH_LAST_PCMが偶数番目か奇数番目か
CH_KEY_STAT:	.ds.b		1		* (.b) KEY 状態 $01=keyon $80=keyoff $00=non
CH_PLAY_FLAG:	.ds.b		1		* (.b) 演奏フラグ(演奏中=$ff/演奏終了=$00)
CH_USER_FRQ:	.ds.b		1		* (.b) ユーザが指定した周波数
CH_PCM_KIND:	.ds.b		1		* (.b) 登録されているPCMの種類
						*	$ff=ADPCM / $00=none / $01=16bit / $02=8bit
		.even
CH_DEBUG_PCM_HEADER_ADR:.ds.l	1		* (.l) デバッグ用 PCM登録ヘッダアドレス


		.offset		0		* 効果音専用チャンネルのワーク

EFCT_JMP_ADR:	.ds.l		1		* (.l) 処理ルーチンアドレス(周波数による)
EFCT_PCM_ADR:	.ds.l		1		* (.l) 現在再生中のPCMアドレス
EFCT_PCM_LEN:	.ds.l		1		* (.l) 残りPCMの長さ
EFCT_CTBL_ADR:	.ds.l		1		* (.l) チェーンテーブルアドレス
EFCT_CH_MASK:	.ds.l		1		* (.l) チャンネルマスク
EFCT_AtoP_X:	.ds.l		1		* (.l) ADPCM -> PCM 変換テーブルアドレス
EFCT_AtoP_Y:	.ds.w		1		* (.w) ADPCM -> PCM 変換 Y
EFCT_CTBL_N:	.ds.w		1		* (.w) チェーンテーブル処理数
EFCT_PAN:	.ds.w		1		* (.w) PCMのPAN(0-127)
EFCT_FRQ:	.ds.w		1		* (.w) PCMのFRQ
EFCT_PLAY_FLAG:	.ds.b		1		* (.b) 演奏状態フラグ
EFCT_PLAY_MODE:	.ds.b		1		* (.b) 再生モード(00:通常 01:アレイ 02:リンクアレイ)
EFCT_PCM_KIND:	.ds.b		1		* (.b) 登録されているPCMの種類
		.text

*▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽
*
*		常駐部分データ
*
*△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△

*		初期化関係

		.align		4

header:		.dc.b		'mPCm/WAC'	* 常駐判定用ヘッダ
trap1_vec_buff:	.ds.l		1		* trap #1 ベクタ保存
DMA_vec_buff:	.ds.l		1		* DMA転送終了割り込みベクタ保存
DMAERR_vec_buff:.ds.l		1		* DMA転送エラー割り込みベクタ保存
iocs_vecs:	.ds.l		8		* 元のIOCSベクタ保存
mpcm_locked:	.dc.b		0		* 占有カウント(0:unlocked / 1-$ff:locked)
mpcm_debug:	.dc.b		0		* デバッグフラグ

*		TRAP #1 関係
trap1_sr_mask:	.dc.w		$0200		* trap #1 実行中の sr のmask
trap1_nest:	.dc.w		-1		* trap #1 呼出ネスト回数

*		DMA 割り込み関係

		.align		4
ch0_work:	.ds.b		CH_WORK_SIZE*CH_MAX	* 各PCMチャンネルのワーク

efct0_work:	.ds.b		EFCT_WORK_SIZE*EFCT_MAX	* 効果音チャンネル

IOCS_work:	.ds.b		EFCT_WORK_SIZE		* IOCS用の1チャンネル

		.align		4
IOCS_REC_LEN:	.ds.l		1		* ADPCM録音時の残り長さ
IOCS_REC_CTBL_ADR:.ds.l		1		* (.l) チェーンテーブルアドレス
IOCS_REC_CTBL_N:.ds.w		1		* (.l) チェーンテーブル処理数


		.align		4
PtoA_X:		.dc.l		PtoA_tbl	* PCM -> ADPCM 変換テーブルアドレス
PtoA_Y:		.dc.w		0		* PCM -> ADPCM 予測値
ADPCM_pan:	.dc.b		0		* ADPCM の PAN
pan_set_flag:	.dc.b		0		* pan設定フラグ
play_flag:	.dc.l		0		* チャンネル演奏状態(bit 1=play/0=off)
mpcm_nest:	.dc.w		-1		* mpcm多重割り込みの回数
overload_ctr:	.dc.w		-100		* 過負荷時のカウンタ
IMR_mask:	.dc.l		$00df0000	* 割り込み中の MFP mask(MFP+$12から)
MPU_mask:	.dc.w		$0300		* 割り込み中の mpu mask
ADPCM_out_flag:	.dc.b		-1		* ADPCM 出力バッファセレクタ
DMA_err_stat:	.dc.b		0		* DMAエラーコード(CERレジスタの内容)
mpcm_mode:	.dc.l		$00000000	* MPCM 動作モードの状態
efct_poly:	.dc.w		$0000		* 効果音発声数
frq_offset:	.dc.w		$0000		* 内臓ADPCM高音質化対応JMPテーブルオフセット
pitch_mode:	.dc.b		$00		* 音程固定フラグ
volume_mode:	.dc.b		$00		* 音量固定フラグ

	.ifdef	DEBUG
ofwrite:		.dc.l		TEXT_RAM	* オーバーフロー検出書き込みアドレス
	.endif
	.ifdef	FCTRACE
fc_logadr:		.dc.l		TEXT_RAM+$40000	* 関数呼びだしログバッファ
	.endif

mplock_app_name:.ds.b		32*32		* mpcmをロックしているアプリ名称バッファ

		.even

PCM_out:	.ds.b		MIX_SIZE*4	* PCM 合成用バッファ
ADPCM_out0:	.ds.b		MIX_SIZE	* ADPCM 作成/出力用バッファ0
ADPCM_out1:	.ds.b		MIX_SIZE	* ADPCM 作成/出力用バッファ1

dummy_ADPCM:	.dc.b		$88,$88,$88,$88,$88,$88,$88,$88	* ダミー再生ADPCM
		.dc.b		$80,$80,$80,$80,$80,$80,$80,$80
		.dc.b		$80,$80,$80,$80,$80,$80,$80,$80
		.dc.b		$80,$80,$80,$80,$80,$80,$80,$80
		.dc.b		$80,$80,$80,$80,$80,$80,$80,$80
		.dc.b		$80,$80,$80,$80,$80,$80,$80,$80

		.align		4
mpw:							* システムワークポインタアドレス

pan_tbl3:	.dc.b		$03,$01,$02,$00		*   3段階指定
pan_tbl128:	.dc.b		$01,$00,$00,$02		* 128段階指定

		.align		4

*		効果音用再生ルーチンのジャンプテーブル
							* ADPCM動作周波数
							* 7kHz		15kHz		31kHz
AtoP_EFCT_tbl:	.dc.l		AtoP_EFCT01_08		* (none)	(none)		3.9kHz	
		.dc.l		AtoP_EFCT01_06		* (none)	(none)		5.2kHz
		.dc.l		AtoP_EFCT01_04		* (none)	3.9kHz		7.8kHz
		.dc.l		AtoP_EFCT01_03		* (none)	5.2kHz		10.4kHz
		.dc.l		AtoP_EFCT01_02		* 3.9kHz	7.8kHz		15.6kHz
		.dc.l		AtoP_EFCT02_03		* 5.2kHz	10.4kHz		20.8kHz
		.dc.l		AtoP_EFCT01_01		* 7.8kHz	15.6kHz		31.2kHz
		.dc.l		AtoP_EFCT04_03		* 10.4kHz	20.8kHz		(none)
		.dc.l		AtoP_EFCT02_01		* 15.6kHz	31.2kHz		(none)
		.dc.l		AtoP_EFCT08_03		* 20.8kHz	(none)		(none)
		.dc.l		AtoP_EFCT04_01		* 31.2kHz	(none)		(none)

PCM16_EFCT_tbl:	.dc.l		PCM16_EFCT01_08
		.dc.l		PCM16_EFCT01_06
		.dc.l		PCM16_EFCT01_04
		.dc.l		PCM16_EFCT01_03
		.dc.l		PCM16_EFCT01_02
		.dc.l		PCM16_EFCT02_03
		.dc.l		PCM16_EFCT01_01
		.dc.l		PCM16_EFCT04_03
		.dc.l		PCM16_EFCT02_01
		.dc.l		PCM16_EFCT08_03
		.dc.l		PCM16_EFCT04_01

PCM8_EFCT_tbl:	.dc.l		PCM8_EFCT01_08
		.dc.l		PCM8_EFCT01_06
		.dc.l		PCM8_EFCT01_04
		.dc.l		PCM8_EFCT01_03
		.dc.l		PCM8_EFCT01_02
		.dc.l		PCM8_EFCT02_03
		.dc.l		PCM8_EFCT01_01
		.dc.l		PCM8_EFCT04_03
		.dc.l		PCM8_EFCT02_01
		.dc.l		PCM8_EFCT08_03
		.dc.l		PCM8_EFCT04_01

*		演奏用再生ルーチンのジャンプテーブル

AtoP_high_tbl:	.dc.l		AtoP_high_v00,AtoP_high_v01,AtoP_high_v02,AtoP_high_v03
		.dc.l		AtoP_high_v04,AtoP_high_v05,AtoP_high_v06,AtoP_high_v07
		.dc.l		AtoP_high_v08,AtoP_high_v09,AtoP_high_v10,AtoP_high_v11
		.dc.l		AtoP_high_v12,AtoP_high_v13,AtoP_high_v14,AtoP_high_v15
		.dc.l		AtoP_high_vnn,AtoP_high_non

AtoP_low_tbl:	.dc.l		AtoP_low_v00,AtoP_low_v01,AtoP_low_v02,AtoP_low_v03
		.dc.l		AtoP_low_v04,AtoP_low_v05,AtoP_low_v06,AtoP_low_v07
		.dc.l		AtoP_low_v08,AtoP_low_v09,AtoP_low_v10,AtoP_low_v11
		.dc.l		AtoP_low_v12,AtoP_low_v13,AtoP_low_v14,AtoP_low_v15
		.dc.l		AtoP_low_vnn,AtoP_low_non

AtoP_0101_tbl:	.dc.l		AtoP_0101_v00,AtoP_0101_v01,AtoP_0101_v02,AtoP_0101_v03
		.dc.l		AtoP_0101_v04,AtoP_0101_v05,AtoP_0101_v06,AtoP_0101_v07
		.dc.l		AtoP_0101_v08,AtoP_0101_v09,AtoP_0101_v10,AtoP_0101_v11
		.dc.l		AtoP_0101_v12,AtoP_0101_v13,AtoP_0101_v14,AtoP_0101_v15
		.dc.l		AtoP_0101_vnn,AtoP_0101_non

AtoP_0203_tbl:	.dc.l		AtoP_0203_v00,AtoP_0203_v01,AtoP_0203_v02,AtoP_0203_v03
		.dc.l		AtoP_0203_v04,AtoP_0203_v05,AtoP_0203_v06,AtoP_0203_v07
		.dc.l		AtoP_0203_v08,AtoP_0203_v09,AtoP_0203_v10,AtoP_0203_v11
		.dc.l		AtoP_0203_v12,AtoP_0203_v13,AtoP_0203_v14,AtoP_0203_v15
		.dc.l		AtoP_0203_vnn,AtoP_0203_non

AtoP_0102_tbl:	.dc.l		AtoP_0102_v00,AtoP_0102_v01,AtoP_0102_v02,AtoP_0102_v03
		.dc.l		AtoP_0102_v04,AtoP_0102_v05,AtoP_0102_v06,AtoP_0102_v07
		.dc.l		AtoP_0102_v08,AtoP_0102_v09,AtoP_0102_v10,AtoP_0102_v11
		.dc.l		AtoP_0102_v12,AtoP_0102_v13,AtoP_0102_v14,AtoP_0102_v15
		.dc.l		AtoP_0102_vnn,AtoP_0102_non

AtoP_0103_tbl:	.dc.l		AtoP_0103_v00,AtoP_0103_v01,AtoP_0103_v02,AtoP_0103_v03
		.dc.l		AtoP_0103_v04,AtoP_0103_v05,AtoP_0103_v06,AtoP_0103_v07
		.dc.l		AtoP_0103_v08,AtoP_0103_v09,AtoP_0103_v10,AtoP_0103_v11
		.dc.l		AtoP_0103_v12,AtoP_0103_v13,AtoP_0103_v14,AtoP_0103_v15
		.dc.l		AtoP_0103_vnn,AtoP_0103_non

AtoP_0104_tbl:	.dc.l		AtoP_0104_v00,AtoP_0104_v01,AtoP_0104_v02,AtoP_0104_v03
		.dc.l		AtoP_0104_v04,AtoP_0104_v05,AtoP_0104_v06,AtoP_0104_v07
		.dc.l		AtoP_0104_v08,AtoP_0104_v09,AtoP_0104_v10,AtoP_0104_v11
		.dc.l		AtoP_0104_v12,AtoP_0104_v13,AtoP_0104_v14,AtoP_0104_v15
		.dc.l		AtoP_0104_vnn,AtoP_0104_non

PCM16_high_tbl:	.dc.l		PCM16_high_v00,PCM16_high_v01,PCM16_high_v02,PCM16_high_v03
		.dc.l		PCM16_high_v04,PCM16_high_v05,PCM16_high_v06,PCM16_high_v07
		.dc.l		PCM16_high_v08,PCM16_high_v09,PCM16_high_v10,PCM16_high_v11
		.dc.l		PCM16_high_v12,PCM16_high_v13,PCM16_high_v14,PCM16_high_v15
		.dc.l		PCM16_high_vnn,PCM16_high_non

PCM16_low_tbl:	.dc.l		PCM16_low_v00,PCM16_low_v01,PCM16_low_v02,PCM16_low_v03
		.dc.l		PCM16_low_v04,PCM16_low_v05,PCM16_low_v06,PCM16_low_v07
		.dc.l		PCM16_low_v08,PCM16_low_v09,PCM16_low_v10,PCM16_low_v11
		.dc.l		PCM16_low_v12,PCM16_low_v13,PCM16_low_v14,PCM16_low_v15
		.dc.l		PCM16_low_vnn,PCM16_low_non

PCM16_0101_tbl:.dc.l		PCM16_0101_v00,PCM16_0101_v01,PCM16_0101_v02,PCM16_0101_v03
		.dc.l		PCM16_0101_v04,PCM16_0101_v05,PCM16_0101_v06,PCM16_0101_v07
		.dc.l		PCM16_0101_v08,PCM16_0101_v09,PCM16_0101_v10,PCM16_0101_v11
		.dc.l		PCM16_0101_v12,PCM16_0101_v13,PCM16_0101_v14,PCM16_0101_v15
		.dc.l		PCM16_0101_vnn,PCM16_0101_non

PCM16_0203_tbl:.dc.l		PCM16_0203_v00,PCM16_0203_v01,PCM16_0203_v02,PCM16_0203_v03
		.dc.l		PCM16_0203_v04,PCM16_0203_v05,PCM16_0203_v06,PCM16_0203_v07
		.dc.l		PCM16_0203_v08,PCM16_0203_v09,PCM16_0203_v10,PCM16_0203_v11
		.dc.l		PCM16_0203_v12,PCM16_0203_v13,PCM16_0203_v14,PCM16_0203_v15
		.dc.l		PCM16_0203_vnn,PCM16_0203_non

PCM16_0102_tbl:	.dc.l		PCM16_0102_v00,PCM16_0102_v01,PCM16_0102_v02,PCM16_0102_v03
		.dc.l		PCM16_0102_v04,PCM16_0102_v05,PCM16_0102_v06,PCM16_0102_v07
		.dc.l		PCM16_0102_v08,PCM16_0102_v09,PCM16_0102_v10,PCM16_0102_v11
		.dc.l		PCM16_0102_v12,PCM16_0102_v13,PCM16_0102_v14,PCM16_0102_v15
		.dc.l		PCM16_0102_vnn,PCM16_0102_non

PCM16_0103_tbl:	.dc.l		PCM16_0103_v00,PCM16_0103_v01,PCM16_0103_v02,PCM16_0103_v03
		.dc.l		PCM16_0103_v04,PCM16_0103_v05,PCM16_0103_v06,PCM16_0103_v07
		.dc.l		PCM16_0103_v08,PCM16_0103_v09,PCM16_0103_v10,PCM16_0103_v11
		.dc.l		PCM16_0103_v12,PCM16_0103_v13,PCM16_0103_v14,PCM16_0103_v15
		.dc.l		PCM16_0103_vnn,PCM16_0103_non

PCM16_0104_tbl:	.dc.l		PCM16_0104_v00,PCM16_0104_v01,PCM16_0104_v02,PCM16_0104_v03
		.dc.l		PCM16_0104_v04,PCM16_0104_v05,PCM16_0104_v06,PCM16_0104_v07
		.dc.l		PCM16_0104_v08,PCM16_0104_v09,PCM16_0104_v10,PCM16_0104_v11
		.dc.l		PCM16_0104_v12,PCM16_0104_v13,PCM16_0104_v14,PCM16_0104_v15
		.dc.l		PCM16_0104_vnn,PCM16_0104_non

PCM8_high_tbl:	.dc.l		PCM8_high_v00,PCM8_high_v01,PCM8_high_v02,PCM8_high_v03
		.dc.l		PCM8_high_v04,PCM8_high_v05,PCM8_high_v06,PCM8_high_v07
		.dc.l		PCM8_high_v08,PCM8_high_v09,PCM8_high_v10,PCM8_high_v11
		.dc.l		PCM8_high_v12,PCM8_high_v13,PCM8_high_v14,PCM8_high_v15
		.dc.l		PCM8_high_vnn,PCM8_high_non

PCM8_low_tbl:	.dc.l		PCM8_low_v00,PCM8_low_v01,PCM8_low_v02,PCM8_low_v03
		.dc.l		PCM8_low_v04,PCM8_low_v05,PCM8_low_v06,PCM8_low_v07
		.dc.l		PCM8_low_v08,PCM8_low_v09,PCM8_low_v10,PCM8_low_v11
		.dc.l		PCM8_low_v12,PCM8_low_v13,PCM8_low_v14,PCM8_low_v15
		.dc.l		PCM8_low_vnn,PCM8_low_non

PCM8_0101_tbl:	.dc.l		PCM8_0101_v00,PCM8_0101_v01,PCM8_0101_v02,PCM8_0101_v03
		.dc.l		PCM8_0101_v04,PCM8_0101_v05,PCM8_0101_v06,PCM8_0101_v07
		.dc.l		PCM8_0101_v08,PCM8_0101_v09,PCM8_0101_v10,PCM8_0101_v11
		.dc.l		PCM8_0101_v12,PCM8_0101_v13,PCM8_0101_v14,PCM8_0101_v15
		.dc.l		PCM8_0101_vnn,PCM8_0101_non

PCM8_0203_tbl:	.dc.l		PCM8_0203_v00,PCM8_0203_v01,PCM8_0203_v02,PCM8_0203_v03
		.dc.l		PCM8_0203_v04,PCM8_0203_v05,PCM8_0203_v06,PCM8_0203_v07
		.dc.l		PCM8_0203_v08,PCM8_0203_v09,PCM8_0203_v10,PCM8_0203_v11
		.dc.l		PCM8_0203_v12,PCM8_0203_v13,PCM8_0203_v14,PCM8_0203_v15
		.dc.l		PCM8_0203_vnn,PCM8_0203_non

PCM8_0102_tbl:	.dc.l		PCM8_0102_v00,PCM8_0102_v01,PCM8_0102_v02,PCM8_0102_v03
		.dc.l		PCM8_0102_v04,PCM8_0102_v05,PCM8_0102_v06,PCM8_0102_v07
		.dc.l		PCM8_0102_v08,PCM8_0102_v09,PCM8_0102_v10,PCM8_0102_v11
		.dc.l		PCM8_0102_v12,PCM8_0102_v13,PCM8_0102_v14,PCM8_0102_v15
		.dc.l		PCM8_0102_vnn,PCM8_0102_non

PCM8_0103_tbl:	.dc.l		PCM8_0103_v00,PCM8_0103_v01,PCM8_0103_v02,PCM8_0103_v03
		.dc.l		PCM8_0103_v04,PCM8_0103_v05,PCM8_0103_v06,PCM8_0103_v07
		.dc.l		PCM8_0103_v08,PCM8_0103_v09,PCM8_0103_v10,PCM8_0103_v11
		.dc.l		PCM8_0103_v12,PCM8_0103_v13,PCM8_0103_v14,PCM8_0103_v15
		.dc.l		PCM8_0103_vnn,PCM8_0103_non

PCM8_0104_tbl:	.dc.l		PCM8_0104_v00,PCM8_0104_v01,PCM8_0104_v02,PCM8_0104_v03
		.dc.l		PCM8_0104_v04,PCM8_0104_v05,PCM8_0104_v06,PCM8_0104_v07
		.dc.l		PCM8_0104_v08,PCM8_0104_v09,PCM8_0104_v10,PCM8_0104_v11
		.dc.l		PCM8_0104_v12,PCM8_0104_v13,PCM8_0104_v14,PCM8_0104_v15
		.dc.l		PCM8_0104_vnn,PCM8_0104_non


*▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽
*
*		ファンクションコール TRAP #1 処理
*
*△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△


		.dc.b		'MPCM/040'
mpcm_trap1:	addi.w		#1,trap1_nest
		bgt		trap1_nested		* trap#1 処理中に再び呼び出された
		movem.l		d1-d7/a0-a6,-(sp)

		lea.l		mpw(pc),a6		* a6.l = trap#1用ワーク先頭アドレス

.ifdef	FCTRACE
		movea.l		fc_logadr-mpw(a6),a0
		move.w		d0,(a0)+
		move.l		a0,fc_logadr-mpw(a6)
.endif

		tst.w		d0			* $8000 <= d0.w ?
		bmi		special_func		* MPCM制御
		cmpi.w		#$1000,d0
		bcc		effect_func		* 効果音制御

normal_func:	cmpi.b		#$ff,d0
		beq		normal_func_all		* 全チャンネル指定
		cmpi.w		#$07FF+1,d0
		bcc		func_error		* ファンクション番号異常

		moveq.l		#0,d7
		move.b		d0,d7			* d7.w = チャンネル番号
		cmpi.w		#CH_MAX,d7
		bcc		func_error		* チャンネル番号チェック

		lsl.w		#7,d7			* CH * CH_WORK_SIZE(128)
		lea.l		ch0_work(pc),a5
		adda.w		d7,a5			* a5.l = 各チャンネルワークのアドレス

		clr.b		d0			* 下位8bit殺す
		lsr.w		#6,d0
		move.l		trap1_jmp_tbl0(pc,d0.w),a0
		pea.l		trap1_ret(pc)
		jmp		(a0)			* 各ファンクションへ

normal_func_all:cmpi.w		#$07FF+1,d0
		bcc		func_error		* ファンクション番号異常

		clr.b		d0			* 下位8bit殺す
		lsr.w		#6,d0
		move.l		trap1_jmp_tbl0(pc,d0.w),a0	* a0.l = ファンクションアドレス
		lea.l		ch0_work+CH_WORK_SIZE*(CH_MAX-1)(pc),a5
		moveq.l		#CH_MAX-1,d0		* 全チャンネル指定
@@:		movem.l		d0-d6/a0-a4,-(sp)
		jsr		(a0)
		movem.l		(sp)+,d0-d6/a0-a4
		lea.l		-CH_WORK_SIZE(a5),a5
		dbra		d0,@b
		bra		trap1_ret		* 終了


trap1_jmp_tbl0:	.dc.l		func_00xx		* PCM KEY ON
		.dc.l		func_01xx		* PCM KEY OFF
		.dc.l		func_02xx		* PCM データ登録
		.dc.l		func_03xx		* PCM 再生周波数設定
		.dc.l		func_04xx		* PCM 音程設定
		.dc.l		func_05xx		* PCM 音量設定
		.dc.l		func_06xx		* PCM PAN設定
		.dc.l		func_07xx		* PCM 種類変更


effect_func:	cmpi.b		#$ff,d0
		beq		effect_func_all		* 全チャンネル指定
		cmpi.b		#$e0,d0
		bcc		effect_func_free	* 空きチャンネル

		cmpi.w		#$13FF+1,d0
		bcc		func_error		* ファンクション番号異常
		moveq.l		#0,d7
		move.b		d0,d7			* d7.w = チャンネル番号
		cmpi.w		#EFCT_MAX,d7
		bcc		func_error		* チャンネル番号チェック

		lsl.w		#6,d7			* CH * EFCT_WORK_SIZE(64)
		lea.l		efct0_work(pc),a5
		adda.w		d7,a5			* a5.l = 各チャンネルワークのアドレス

		clr.b		d0			* 下位8bit殺す
		subi.w		#$1000,d0		* 上位から$1000を引く
		lsr.w		#6,d0
*		move.l		trap1_jmp_tbl1(pc,d0.w),a0	* rerative err!!
		lea.l		trap1_jmp_tbl1(pc),a0
		move.l		(a0,d0.w),a0
		pea.l		trap1_ret(pc)
		jmp		(a0)			* 各ファンクションへ

effect_func_free:
		cmpi.w		#$13FF+1,d0
		bcc		func_error		* ファンクション番号異常

		lea.l		efct0_work(pc),a5
		move.w		efct_poly-mpw(a6),d7	* 効果音ポリフォニック数
		bmi		func_error		* -1 は発音無し

		move.l		a5,a0
		move.w		d7,d5
		move.l		EFCT_PCM_LEN(a0),d6	* 一番残りが短いやつを探す
1:		tst.b		EFCT_PLAY_FLAG(a5)
		beq		3f			* 空いていた!
		cmp.l		EFCT_PCM_LEN(a5),d6
		bmi		2f
		movea.l		a5,a0
		move.w		d7,d5
		move.l		EFCT_PCM_LEN(a0),d6	* 現在のやつが一番短い
2:		lea.l		EFCT_WORK_SIZE(a5),a5
		dbra		d7,1b

		* 空きがない処理

		movea.l		a0,a5			* 再生データの残りが一番少ないチャンネル
		move.w		d5,d7

		* 空きがあった時
3:		move.l		d7,-(sp)		* 使用チャンネル番号保存
		clr.b		d0			* 下位8bit殺す
		subi.w		#$1000,d0
		lsr.w		#6,d0
		move.l		trap1_jmp_tbl1(pc,d0.w),a0
		jsr		(a0)			* 各ファンクションへ
		move.l		(sp)+,d0		* 使用チャンネル番号復帰
		bra		trap1_ret

effect_func_all:cmpi.w		#$13FF+1,d0
		bcc		func_error		* ファンクション番号異常

		clr.b		d0			* 下位8bit殺す
		subi.w		#$1000,d0
		lsr.w		#6,d0

		move.l		trap1_jmp_tbl1(pc,d0.w),a0	* a0.l = ファンクションアドレス
		lea.l		efct0_work(pc),a5
		move.w		#EFCT_MAX-1,d0		* 全チャンネル指定
@@:		movem.l		d0-d6/a0-a4,-(sp)
		jsr		(a0)
		movem.l		(sp)+,d0-d6/a0-a4
		lea.l		EFCT_WORK_SIZE(a5),a5
		dbra		d0,@b
		bra		trap1_ret		* 終了

trap1_jmp_tbl1:	.dc.l		func_10xx		* 効果音再生
		.dc.l		reserved
		.dc.l		reserved
		.dc.l		func_13xx		* 効果音停止


special_func:	cmpi.w		#$8013+1,d0
		bcc		func_error		* そんなファンクション番号はないよ
		add.w		d0,d0
		add.w		d0,d0
		move.l		trap1_jmp_tbl2(pc,d0.w),a0
		pea.l		trap1_ret(pc)
		jmp		(a0)

trap1_jmp_tbl2:	.dc.l		func_8000		* 占有する
		.dc.l		func_8001		* 占有を解除する
		.dc.l		func_8002		* 初期化
		.dc.l		func_8003		* 割り込みマスク設定
		.dc.l		func_8004		* MPCM動作モード設定
		.dc.l		func_8005		* 音量マップ設定
		.dc.l		func_8006		* 効果音チャンネル最大数設定
		.dc.l		reserved
		.dc.l		reserved
		.dc.l		reserved
		.dc.l		reserved
		.dc.l		reserved
		.dc.l		reserved
		.dc.l		reserved
		.dc.l		reserved
		.dc.l		reserved
		.dc.l		func_8010		* チャンネルワークアドレス収得
		.dc.l		func_8011		* システムワークアドレス収得
		.dc.l		func_8012		* チャンネル別処理アドレス収得
		.dc.l		func_8013		* 全体処理アドレス収得

reserved:
func_error:	moveq.l		#-1,d0
trap1_ret:	movem.l		(sp)+,d1-d7/a0-a6
trap1_nested:	sub.w		#1,trap1_nest
		rte

*===============================================================
* func_00xx	: PCM KEY ON
* call		: a5.l	＝ チャンネルワークアドレス
* return	: d0.l	≧ 0	: 正常終了
*		  	＜ 0	: 録音中でKEY ON できない
*===============================================================

func_00xx:	btst.b		#2,ADPCM_SYSWORK.w	* 録音中?
		beq		@f
		moveq.l		#-1,d0
		rts					* ならキーオンしない

@@:		move.b		#$01,CH_KEY_STAT(a5)	* キーオン
		st.b		CH_PLAY_FLAG(a5)	* 演奏中

		tst.l		play_flag-mpw(a6)
		beq		func_00xx_DMA_start
		moveq.l		#0,d0
		rts

func_00xx_DMA_start:
		lea.l		DMA3,a0
		move.b		#$10,DCCR(a0)		* CCR DMA停止割り込み無し

		move.l		#PtoA_tbl,PtoA_X-mpw(a6)	* PCM -> ADPCM ワーク初期化
		clr.w		PtoA_Y-mpw(a6)
		st.b		ADPCM_out_flag-mpw(a6)

		move.w		#$8002,DCR(a0)		* 初期演奏は空演奏
		move.b		#$04,SCR(a0)
		move.b		#$01,CPR(a0)

		moveq.l		#MIX_SIZE,d1
		moveq.l		#5,d2
		lea.l		dummy_ADPCM-mpw(a6),a1

		move.l		#ADPCM+3,DAR(a0)	* ADPCM データレジスタ
		move.b		d2,DFC(a0)		* move.b #$05,DFC(a0)

		move.w		d1,MTC(a0)		* $88+$80を1回分転送
		move.b		d2,MFC(a0)
		move.l		a1,MAR(a0)

		move.w		d1,BTC(a0)		* $88+$80をもう1回分転送
		move.b		d2,BFC(a0)
		move.l		a1,BAR(a0)

		move.b		CSR(a0),CSR(a0)		* CSR all clear
		move.b		#$c8,DCCR(a0)		* 動作開始/継続モード/転送終了割込あり

		move.b		#$02,ADPCM+1		* ADPCM play start(念のため)
		rts

*===============================================================
* func_01xx	: PCM KEY OFF
* call		: a5.l = チャンネルワークアドレス
* return	: d0.l ≧ 0			: 正常終了
*===============================================================

func_01xx:	st.b		CH_KEY_STAT(a5)		* key off
		moveq.l		#0,d0
		rts

*===============================================================
* func_02xx	: PCM データ登録
* call		: d1.l = 0 (将来拡張用)
*		  a1.l = PCM情報テーブルアドレス
*			$0000(a1).b = PCM種類(-1:ADPCM 0:データ無し 1:16bitPCM 2:8bitPCM)
*			$0001(a1).b = PCMのオリジナルノート番号(0～127,負の場合は原音程固定再生)
*			$0002-$0003(a1).b = 何でもよい
*			$0004(a1).l = PCMアドレス(絶対番地)
*			$0008(a1).l = PCMの長さ
*			$000c(a1).l = ループ開始点オフセット
*			$0010(a1).l = ループ終了点オフセット
*			$0014(a1).l = ループ回数(0で無限ループ、通常は1)
*		  a5.l = チャンネルワークアドレス
* return	: d0.l ≧ 0		: 正常終了
*		        < 0		: 登録失敗
*			   原因としては、16bitPCM登録時に、
*			   アドレス、長さ、ループポインタのいずれかが奇数である、などなど
*===============================================================

func_02xx:
		move.b		(a1)+,d1		* PCM種類
		beq		f02xx_noPCM		*  0: データ無し

		moveq.l		#0,d2
		move.b		(a1)+,d2		* オリジナルノート
		lsl.w		#6,d2			* 64倍
		addq.l		#2,a1			* アドレス補正
		move.b		d1,CH_PCM_KIND(a5)	* PCM種類登録
		bmi		f02xx_ADPCM		* -1: ADPCM
		subq.b		#2,d1			
		bmi		f02xx_PCM16		*  1: 16bit PCM
		beq		f02xx_PCM8		*  2: 8bit PCM

func_02xx_err:	clr.b		CH_PLAY_FLAG(a6)	* 演奏中止
		clr.b		CH_KEY_STAT(a6)		* non
*		clr.b		CH_PCM_KIND(a5)		* PCM種類 = none
		moveq.l		#-1,d0			* 種類がおかしいよ！
		bra		f02xx_noPCMxx		* 演奏しない

* 		ADPCM 登録

f02xx_ADPCM:	clr.b		CH_PLAY_FLAG(a6)	* 演奏中止
		clr.b		CH_KEY_STAT(a6)
		move.w		d2,CH_ORG_NOTE(a5)	* オリジナルノート登録
		move.w		d2,CH_USER_NOTE(a5)	* ユーザー指定ノートも書きかえる
		movea.l		(a1)+,a0		* a0.l = ADPCM先頭アドレス
		move.l		a0,CH_TOP_ADR(a5)
		move.l		(a1)+,d2		* ADPCM長さ
		add.l		a0,d2			* d2.l = ADPCM終了アドレス+1を差す
		move.l		d2,CH_END_ADR(a5)
		move.l		(a1)+,d2		* ループ先頭オフセット
		add.l		a0,d2			* d2.l = ループ先頭アドレスを差す
		move.l		d2,CH_LPSTART_ADR(a5)
		addq.l		#1,a0			* ループ終端オフセット
		adda.l		(a1)+,a0		* a0.l = ループ終端アドレス+1を差す
		move.l		a0,CH_LPEND_ADR(a5)
		move.l		(a1)+,CH_LPTIME(a5)	*  ループ回数(0で無限ループ)
		move.l		#CALC_TPCNSTADP,CH_TPCNST_CADR(a5)	* アドレス増分計算アドレス

		move.w		CH_USER_NOTE(a5),d1
		bra		func_04xx_x		* 音程再設定

*		16bitPCM 登録

f02xx_PCM16:	clr.b		CH_PLAY_FLAG(a6)	* 演奏中止
		clr.b		CH_KEY_STAT(a6)
		move.w		d2,CH_ORG_NOTE(a5)	* オリジナルノート登録
*		move.w		d2,CH_USER_NOTE(a5)	* ユーザー指定ノートも書きかえる
		move.l		(a1)+,d3		* d3.l = 16bitPCM 先頭アドレス
		btst.l		#0,d3
		bne		func_02xx_err		* 偶数じゃないぞ
		move.l		d3,CH_TOP_ADR(a5)
		move.l		(a1)+,d2		* 16bitPCM長さ
		add.l		d3,d2			* d2.l = 終了アドレス+1を差す
		btst.l		#0,d2
		bne		func_02xx_err		* 偶数じゃないぞ
		move.l		d2,CH_END_ADR(a5)
		move.l		(a1)+,d2		* ループ先頭オフセット
		add.l		d3,d2			* d2.l = ループ先頭アドレスを差す
		btst.l		#0,d2
		bne		func_02xx_err		* 偶数じゃないぞ
		move.l		d2,CH_LPSTART_ADR(a5)
		move.l		(a1)+,d2		* ループ終端オフセット
		addq.l		#2,d2			* 16bitPCMだから2足す
		add.l		d3,d2			* d2.l = ループ終端アドレス+2を差す
		btst.l		#0,d2
		bne		func_02xx_err		* 偶数じゃないぞ
		move.l		d2,CH_LPEND_ADR(a5)
		move.l		(a1)+,CH_LPTIME(a5)	* ループ回数(0で無限ループ)
		move.l		#CALC_TPCNST16,CH_TPCNST_CADR(a5)	* アドレス増分計算アドレス

		move.w		CH_USER_NOTE(a5),d1
		bra		func_04xx_x		* 音程再設定

*		8bitPCM 登録

f02xx_PCM8:	clr.b		CH_PLAY_FLAG(a6)	* 演奏中止
		clr.b		CH_KEY_STAT(a6)
		move.w		d2,CH_ORG_NOTE(a5)	* オリジナルノート登録
*		move.w		d2,CH_USER_NOTE(a5)	* ユーザー指定ノートも書きかえる
		movea.l		(a1)+,a0		* a0.l = 8bitPCM先頭アドレス
		move.l		a0,CH_TOP_ADR(a5)
		move.l		(a1)+,d2		* 8bitPCM長さ
		add.l		a0,d2			* d2.l = 終了アドレス+1 を差す
		move.l		d2,CH_END_ADR(a5)
		move.l		(a1)+,d2		* ループ先頭オフセット
		add.l		a0,d2			* d2.l = ループ先頭アドレスを差す
		move.l		d2,CH_LPSTART_ADR(a5)
		addq.l		#1,a0			* ループ終端オフセット
		adda.l		(a1)+,a0		* a0.l = ループ終端アドレス+1を差す
		move.l		a0,CH_LPEND_ADR(a5)
		move.l		(a1)+,CH_LPTIME(a5)	* ループ回数(0で無限ループ)
		move.l		#CALC_TPCNST8,CH_TPCNST_CADR(a5)	* アドレス増分計算アドレス

		move.w		CH_USER_NOTE(a5),d1
		bra		func_04xx_x		* 音程再設定

*		データ無し

f02xx_noPCM:	moveq.l		#0,d0			* 戻り値(正常)
f02xx_noPCMxx:	clr.b		CH_PLAY_FLAG(a5)	* 演奏中止(KEY OFFではない)
		clr.b		CH_KEY_STAT(a5)		* KEY OFF状態
		move.l		#CALC_TPCNSTNO,CH_TPCNST_CADR(a5)	* アドレス増分計算アドレス
		move.l		#NO_PCM,CH_JMP_ADR(a5)	* データ無しの場合
		rts

*===============================================================
* func_03xx	: PCM 再生周波数指定
* call		: d1.w = 再生周波数
*			 0 =  3.9kHz
*			 1 =  5.2kHz
*			 2 =  7.8kHz
*			 3 = 10.4kHz
*			 4 = 15.6kHz
*			 5 = 20.8kHz
*			 6 = 31.2kHz
*		  a5.l = チャンネルワークアドレス
* return	: d0.l ≧ 0	正常終了
*                      ＜ 0     異状終了
*===============================================================

func_03xx:	cmp.b		CH_USER_FRQ(a5),d1
		bne		@f
		rts						* 変わらなかったら何もしない
@@:		cmpi.w		#$0006+1,d1
		bcc		@f				* エラーだ
		move.b		d1,CH_USER_FRQ(a5)		* ユーザーが指定した値を保存
		add.w		d1,d1
		add.w		d1,d1
		add.w		frq_offset-mpw(a6),d1	* PCM高音質化対応
		movea.l		func_03xx_tbl(pc,d1.w),a0
		move.l		a0,CH_PITCH_CADR(a5)
		move.l		CH_ORG_PITCH(a5),d1		* オリジナルのピッチを再変換
		jmp		(a0)				* 音程再設定

@@:		moveq.l		#-1,d0
		rts

func_03xx_tbl:
		.dc.l		func_04xx_01_08		* PITCH *  1/ 8
		.dc.l		func_04xx_01_06		* PITCH *  1/ 6
		.dc.l		func_04xx_01_04		* PITCH *  1/ 4
		.dc.l		func_04xx_01_03		* PITCH *  1/ 3
		.dc.l		func_04xx_01_02		* PITCH *  1/ 2
		.dc.l		func_04xx_02_03		* PITCH *  2/ 3
		.dc.l		func_04xx_01_01		* PITCH *  1/ 1
		.dc.l		func_04xx_04_03		* PITCH *  4/ 3
		.dc.l		func_04xx_02_01		* PITCH *  2/ 1
		.dc.l		func_04xx_08_03		* PITCH *  8/ 3
		.dc.l		func_04xx_04_01		* PITCH *  4/ 1

*===============================================================
* func_04xx	: PCM 音程設定
* call		: d1.w = 音程
*			 0～127(ノート番号)*64+0～63(ディチューン)
*			 FM音源と同じ考え(4倍はしなくてよい)
*		  a5.l = チャンネルワークアドレス
* return	: d0.l ≧ 0	正常終了
*		       ＜ 0	エラー(音程が範囲外、など)
*		  special thanks to Z.Nisikawa
*===============================================================

func_04xx:
		cmpi.w		#127*64+63+1,d1
		bcs		@f		
		moveq.l		#-1,d0			* 範囲外
		rts

@@:		move.w		d1,CH_USER_NOTE(a5)	* ユーザー指定のノート保存
func_04xx_x:	move.w		CH_ORG_NOTE(a5),d0
		cmpi.w		#$1fc0+1,d0		* オリジナルキーが負？
		bcs		@f
		moveq.l		#1,d1
		swap.w		d1
		move.l		d1,CH_ORG_PITCH(a5)	* 原音程固定
		movea.l		CH_PITCH_CADR(a5),a0
		jmp		(a0)

@@:		sub.w		d0,d1
		bmi		@f

		moveq.l		#0,d0
1:		subi.w		#64*12,d1
		bcs		2f
		addq.l		#1,d0
		bra		1b
2:		addi.w		#64*12,d1		* d0.l = オクターブの差
		add.w		d1,d1			* d1.w = ノートの差
		moveq.l		#1,d2
		swap.w		d2
		move.w		f04_pitch_tbl(pc,d1.w),d2
		lsl.l		d0,d2			* 左シフト
		move.l		d2,CH_ORG_PITCH(a5)	* 周波数変換前のピッチ
		move.l		d2,d1
		movea.l		CH_PITCH_CADR(a5),a0
		jmp		(a0)

@@:		moveq.l		#0,d0
1:		addi.w		#64*12,d1
		bcs		2f
		addq.l		#1,d0
		bra		1b
2:		addq.l		#1,d0			* d0.l = オクターブの差
		add.w		d1,d1
		moveq.l		#1,d2			* d1.w = ノートの差
		swap.w		d2
		move.w		f04_pitch_tbl(pc,d1.w),d2
		lsr.l		d0,d2			* 右シフト
		move.l		d2,CH_ORG_PITCH(a5)
		movea.l		CH_PITCH_CADR(a5),a0
		move.l		d2,d1
		jmp		(a0)

f04_pitch_tbl:				        * PCMの１オクターブ分の変化テーブル
	                *for i=0 to 768-1:print (2^(i/768)*65536-65536):next
		.dc.w		$0000,$003b,$0076,$00b2,$00ed,$0128,$0164,$019f
		.dc.w		$01db,$0217,$0252,$028e,$02ca,$0305,$0341,$037d
		.dc.w		$03b9,$03f5,$0431,$046e,$04aa,$04e6,$0522,$055f
		.dc.w		$059b,$05d8,$0614,$0651,$068d,$06ca,$0707,$0743
		.dc.w		$0780,$07bd,$07fa,$0837,$0874,$08b1,$08ef,$092c
		.dc.w		$0969,$09a7,$09e4,$0a21,$0a5f,$0a9c,$0ada,$0b18
		.dc.w		$0b56,$0b93,$0bd1,$0c0f,$0c4d,$0c8b,$0cc9,$0d07
		.dc.w		$0d45,$0d84,$0dc2,$0e00,$0e3f,$0e7d,$0ebc,$0efa
		.dc.w		$0f39,$0f78,$0fb6,$0ff5,$1034,$1073,$10b2,$10f1
		.dc.w		$1130,$116f,$11ae,$11ee,$122d,$126c,$12ac,$12eb
		.dc.w		$132b,$136b,$13aa,$13ea,$142a,$146a,$14a9,$14e9
		.dc.w		$1529,$1569,$15aa,$15ea,$162a,$166a,$16ab,$16eb
		.dc.w		$172c,$176c,$17ad,$17ed,$182e,$186f,$18b0,$18f0
		.dc.w		$1931,$1972,$19b3,$19f5,$1a36,$1a77,$1ab8,$1afa
		.dc.w		$1b3b,$1b7d,$1bbe,$1c00,$1c41,$1c83,$1cc5,$1d07
		.dc.w		$1d48,$1d8a,$1dcc,$1e0e,$1e51,$1e93,$1ed5,$1f17
		.dc.w		$1f5a,$1f9c,$1fdf,$2021,$2064,$20a6,$20e9,$212c
		.dc.w		$216f,$21b2,$21f5,$2238,$227b,$22be,$2301,$2344
		.dc.w		$2388,$23cb,$240e,$2452,$2496,$24d9,$251d,$2561
		.dc.w		$25a4,$25e8,$262c,$2670,$26b4,$26f8,$273d,$2781
		.dc.w		$27c5,$280a,$284e,$2892,$28d7,$291c,$2960,$29a5
		.dc.w		$29ea,$2a2f,$2a74,$2ab9,$2afe,$2b43,$2b88,$2bcd
		.dc.w		$2c13,$2c58,$2c9d,$2ce3,$2d28,$2d6e,$2db4,$2df9
		.dc.w		$2e3f,$2e85,$2ecb,$2f11,$2f57,$2f9d,$2fe3,$302a
		.dc.w		$3070,$30b6,$30fd,$3143,$318a,$31d0,$3217,$325e
		.dc.w		$32a5,$32ec,$3332,$3379,$33c1,$3408,$344f,$3496
		.dc.w		$34dd,$3525,$356c,$35b4,$35fb,$3643,$368b,$36d3
		.dc.w		$371a,$3762,$37aa,$37f2,$383a,$3883,$38cb,$3913
		.dc.w		$395c,$39a4,$39ed,$3a35,$3a7e,$3ac6,$3b0f,$3b58
		.dc.w		$3ba1,$3bea,$3c33,$3c7c,$3cc5,$3d0e,$3d58,$3da1
		.dc.w		$3dea,$3e34,$3e7d,$3ec7,$3f11,$3f5a,$3fa4,$3fee
		.dc.w		$4038,$4082,$40cc,$4116,$4161,$41ab,$41f5,$4240
		.dc.w		$428a,$42d5,$431f,$436a,$43b5,$4400,$444b,$4495
		.dc.w		$44e1,$452c,$4577,$45c2,$460d,$4659,$46a4,$46f0
		.dc.w		$473b,$4787,$47d3,$481e,$486a,$48b6,$4902,$494e
		.dc.w		$499a,$49e6,$4a33,$4a7f,$4acb,$4b18,$4b64,$4bb1
		.dc.w		$4bfe,$4c4a,$4c97,$4ce4,$4d31,$4d7e,$4dcb,$4e18
		.dc.w		$4e66,$4eb3,$4f00,$4f4e,$4f9b,$4fe9,$5036,$5084
		.dc.w		$50d2,$5120,$516e,$51bc,$520a,$5258,$52a6,$52f4
		.dc.w		$5343,$5391,$53e0,$542e,$547d,$54cc,$551a,$5569
		.dc.w		$55b8,$5607,$5656,$56a5,$56f4,$5744,$5793,$57e2
		.dc.w		$5832,$5882,$58d1,$5921,$5971,$59c1,$5a10,$5a60
		.dc.w		$5ab0,$5b01,$5b51,$5ba1,$5bf1,$5c42,$5c92,$5ce3
		.dc.w		$5d34,$5d84,$5dd5,$5e26,$5e77,$5ec8,$5f19,$5f6a
		.dc.w		$5fbb,$600d,$605e,$60b0,$6101,$6153,$61a4,$61f6
		.dc.w		$6248,$629a,$62ec,$633e,$6390,$63e2,$6434,$6487
		.dc.w		$64d9,$652c,$657e,$65d1,$6624,$6676,$66c9,$671c
		.dc.w		$676f,$67c2,$6815,$6869,$68bc,$690f,$6963,$69b6
		.dc.w		$6a0a,$6a5e,$6ab1,$6b05,$6b59,$6bad,$6c01,$6c55
		.dc.w		$6caa,$6cfe,$6d52,$6da7,$6dfb,$6e50,$6ea4,$6ef9
		.dc.w		$6f4e,$6fa3,$6ff8,$704d,$70a2,$70f7,$714d,$71a2
		.dc.w		$71f7,$724d,$72a2,$72f8,$734e,$73a4,$73fa,$7450
		.dc.w		$74a6,$74fc,$7552,$75a8,$75ff,$7655,$76ac,$7702
		.dc.w		$7759,$77b0,$7807,$785e,$78b4,$790c,$7963,$79ba
		.dc.w		$7a11,$7a69,$7ac0,$7b18,$7b6f,$7bc7,$7c1f,$7c77
		.dc.w		$7ccf,$7d27,$7d7f,$7dd7,$7e2f,$7e88,$7ee0,$7f38
		.dc.w		$7f91,$7fea,$8042,$809b,$80f4,$814d,$81a6,$81ff
		.dc.w		$8259,$82b2,$830b,$8365,$83be,$8418,$8472,$84cb
		.dc.w		$8525,$857f,$85d9,$8633,$868e,$86e8,$8742,$879d
		.dc.w		$87f7,$8852,$88ac,$8907,$8962,$89bd,$8a18,$8a73
		.dc.w		$8ace,$8b2a,$8b85,$8be0,$8c3c,$8c97,$8cf3,$8d4f
		.dc.w		$8dab,$8e07,$8e63,$8ebf,$8f1b,$8f77,$8fd4,$9030
		.dc.w		$908c,$90e9,$9146,$91a2,$91ff,$925c,$92b9,$9316
		.dc.w		$9373,$93d1,$942e,$948c,$94e9,$9547,$95a4,$9602
		.dc.w		$9660,$96be,$971c,$977a,$97d8,$9836,$9895,$98f3
		.dc.w		$9952,$99b0,$9a0f,$9a6e,$9acd,$9b2c,$9b8b,$9bea
		.dc.w		$9c49,$9ca8,$9d08,$9d67,$9dc7,$9e26,$9e86,$9ee6
		.dc.w		$9f46,$9fa6,$a006,$a066,$a0c6,$a127,$a187,$a1e8
		.dc.w		$a248,$a2a9,$a30a,$a36b,$a3cc,$a42d,$a48e,$a4ef
		.dc.w		$a550,$a5b2,$a613,$a675,$a6d6,$a738,$a79a,$a7fc
		.dc.w		$a85e,$a8c0,$a922,$a984,$a9e7,$aa49,$aaac,$ab0e
		.dc.w		$ab71,$abd4,$ac37,$ac9a,$acfd,$ad60,$adc3,$ae27
		.dc.w		$ae8a,$aeed,$af51,$afb5,$b019,$b07c,$b0e0,$b145
		.dc.w		$b1a9,$b20d,$b271,$b2d6,$b33a,$b39f,$b403,$b468
		.dc.w		$b4cd,$b532,$b597,$b5fc,$b662,$b6c7,$b72c,$b792
		.dc.w		$b7f7,$b85d,$b8c3,$b929,$b98f,$b9f5,$ba5b,$bac1
		.dc.w		$bb28,$bb8e,$bbf5,$bc5b,$bcc2,$bd29,$bd90,$bdf7
		.dc.w		$be5e,$bec5,$bf2c,$bf94,$bffb,$c063,$c0ca,$c132
		.dc.w		$c19a,$c202,$c26a,$c2d2,$c33a,$c3a2,$c40b,$c473
		.dc.w		$c4dc,$c544,$c5ad,$c616,$c67f,$c6e8,$c751,$c7bb
		.dc.w		$c824,$c88d,$c8f7,$c960,$c9ca,$ca34,$ca9e,$cb08
		.dc.w		$cb72,$cbdc,$cc47,$ccb1,$cd1b,$cd86,$cdf1,$ce5b
		.dc.w		$cec6,$cf31,$cf9c,$d008,$d073,$d0de,$d14a,$d1b5
		.dc.w		$d221,$d28d,$d2f8,$d364,$d3d0,$d43d,$d4a9,$d515
		.dc.w		$d582,$d5ee,$d65b,$d6c7,$d734,$d7a1,$d80e,$d87b
		.dc.w		$d8e9,$d956,$d9c3,$da31,$da9e,$db0c,$db7a,$dbe8
		.dc.w		$dc56,$dcc4,$dd32,$dda0,$de0f,$de7d,$deec,$df5b
		.dc.w		$dfc9,$e038,$e0a7,$e116,$e186,$e1f5,$e264,$e2d4
		.dc.w		$e343,$e3b3,$e423,$e493,$e503,$e573,$e5e3,$e654
		.dc.w		$e6c4,$e735,$e7a5,$e816,$e887,$e8f8,$e969,$e9da
		.dc.w		$ea4b,$eabc,$eb2e,$eb9f,$ec11,$ec83,$ecf5,$ed66
		.dc.w		$edd9,$ee4b,$eebd,$ef2f,$efa2,$f014,$f087,$f0fa
		.dc.w		$f16d,$f1e0,$f253,$f2c6,$f339,$f3ad,$f420,$f494
		.dc.w		$f507,$f57b,$f5ef,$f663,$f6d7,$f74c,$f7c0,$f834
		.dc.w		$f8a9,$f91e,$f992,$fa07,$fa7c,$faf1,$fb66,$fbdc
		.dc.w		$fc51,$fcc7,$fd3c,$fdb2,$fe28,$fe9e,$ff14,$ff8a

							* ADPCM BASE FRQ        15.6/31.2 kHz
func_04xx_01_08:lsr.l		#3,d1			* 音程1/8倍		無し/3.9 kHz
		movea.l		CH_TPCNST_CADR(a5),a0
		jmp		(a0)
func_04xx_01_06:moveq.l		#6,d0			* 音程1/6倍		無し/5.2 kHz
		div32_16
		movea.l		CH_TPCNST_CADR(a5),a0
		jmp		(a0)
func_04xx_01_04:lsr.l		#2,d1			* 音程1/4倍		3.9/7.8 kHz
		movea.l		CH_TPCNST_CADR(a5),a0
		jmp		(a0)
func_04xx_01_03:moveq.l		#3,d0			* 音程1/3倍		5.2/10.4 kHz
		div32_16
		movea.l		CH_TPCNST_CADR(a5),a0
		jmp		(a0)
func_04xx_01_02:lsr.l		#1,d1			* 音程1/2倍		7.8/15.6 kHz
		movea.l		CH_TPCNST_CADR(a5),a0
		jmp		(a0)
func_04xx_02_03:add.l		d1,d1			* 音程2/3倍		10.4/20.8 kHz
		moveq.l		#3,d0
		div32_16
		movea.l		CH_TPCNST_CADR(a5),a0
		jmp		(a0)
func_04xx_01_01:movea.l		CH_TPCNST_CADR(a5),a0	* 音程1/1倍(そのまんま)	15.6/31.2 kHz
		jmp		(a0)
func_04xx_04_03:add.l		d1,d1			* 音程4/3倍		20.8/無し kHz
		add.l		d1,d1
		moveq.l		#3,d0
		div32_16
		movea.l		CH_TPCNST_CADR(a5),a0
		jmp		(a0)
func_04xx_02_01:add.l		d1,d1
		movea.l		CH_TPCNST_CADR(a5),a0	* 音程2/1倍		31.2/無し kHz
		jmp		(a0)
func_04xx_08_03:lsl.l		#3,d1			* 音程8/3倍
		moveq.l		#3,d0
		div32_16
		movea.l		CH_TPCNST_CADR(a5),a0
		jmp		(a0)
func_04xx_04_01:add.l		d1,d1
		add.l		d1,d1
		movea.l		CH_TPCNST_CADR(a5),a0	* 音程4/1倍
		jmp		(a0)

CALC_TPCNSTADP:	moveq.l		#0,d0			* 戻り値クリア
		move.w		CH_VOL_OFFS(a5),d4

		cmpi.l		#$0001_0000,d1
		bhi		1f
		beq		2f
		cmpi.w		#$AAAA,d1
		beq		3f
		cmpi.w		#$8000,d1
		beq		4f
		cmpi.w		#$5555,d1
		beq		5f
		cmpi.w		#$4000,d1
		beq		6f
		move.l		d1,d2			* 1回の割り込みで進むアドレス計算
		lsl.l		#4,d2			* ADPCM
		move.l		d2,d3
		add.l		d2,d2
		add.l		d3,d2			* d2.l = CH_PITCH*48
		clr.w		d2
		swap.w		d2
		addq.l		#1,d2			* d2.l = TPCNST

		lea.l		AtoP_low_tbl(pc),a0
		move.l		a0,CH_CNVADR_BASE(a5)
		move.w		sr,d3
		ori.w		#$0700,sr
		move.l		#AtoP_low,CH_JMP_ADR(a5)
		move.l		(a0,d4.w),CH_JMP_ADR2(a5)	* AtoP 低音変換
		move.l		d1,CH_PITCH(a5)
		move.l		d2,CH_TPCNST(a5)
		move.w		d3,sr
		rts

1:		move.l		d1,d2			* 1回の割り込みで進むアドレス計算
		lsl.l		#4,d2			* ADPCM
		move.l		d2,d3
		add.l		d2,d2
		add.l		d3,d2			* d2.l = CH_PITCH*48
		clr.w		d2
		swap.w		d2
		addq.l		#1,d2			* d2.l = TPCNST

		lea.l		AtoP_high_tbl(pc),a0
		move.l		a0,CH_CNVADR_BASE(a5)
		move.w		sr,d3
		ori.w		#$0700,sr
		move.l		#AtoP_high,CH_JMP_ADR(a5)
		move.l		(a0,d4.w),CH_JMP_ADR2(a5)	* AtoP 高音変換
		move.l		d1,CH_PITCH(a5)
		move.l		d2,CH_TPCNST(a5)
		move.w		d3,sr
		rts
2:		lea.l		AtoP_0101_tbl(pc),a0
		move.l		a0,CH_CNVADR_BASE(a5)
		move.w		sr,d3
		ori.w		#$0700,sr
		move.l		#AtoP_0101,CH_JMP_ADR(a5)
		move.l		(a0,d4.w),CH_JMP_ADR2(a5)	* AtoP 15.6kHz
		move.w		d3,sr
		rts
3:		lea.l		AtoP_0203_tbl(pc),a0
		move.l		a0,CH_CNVADR_BASE(a5)
		move.w		sr,d3
		ori.w		#$0700,sr
		move.l		#AtoP_0203,CH_JMP_ADR(a5)
		move.l		(a0,d4.w),CH_JMP_ADR2(a5)	* AtoP 10.4kHz
		move.w		d3,sr
		rts
4:		lea.l		AtoP_0102_tbl(pc),a0
		move.l		a0,CH_CNVADR_BASE(a5)
		move.w		sr,d3
		ori.w		#$0700,sr
		move.l		#AtoP_0102,CH_JMP_ADR(a5)
		move.l		(a0,d4.w),CH_JMP_ADR2(a5)	* AtoP 7.8kHz
		move.w		d3,sr
		rts
5:		lea.l		AtoP_0103_tbl(pc),a0
		move.l		a0,CH_CNVADR_BASE(a5)
		move.w		sr,d3
		ori.w		#$0700,sr
		move.l		#AtoP_0103,CH_JMP_ADR(a5)
		move.l		(a0,d4.w),CH_JMP_ADR2(a5)	* AtoP 5.2kHz
		move.w		d3,sr
		rts
6:		lea.l		AtoP_0104_tbl(pc),a0
		move.l		a0,CH_CNVADR_BASE(a5)
		move.w		sr,d3
		ori.w		#$0700,sr
		move.l		#AtoP_0104,CH_JMP_ADR(a5)
		move.l		(a0,d4.w),CH_JMP_ADR2(a5)	* AtoP 3.8kHz
		move.w		d3,sr
		rts

CALC_TPCNST16:	moveq.l		#0,d0			* 戻り値クリア
		move.w		CH_VOL_OFFS(a5),d4

		cmpi.l		#$0001_0000,d1
		bhi		1f
		beq		2f
		cmpi.w		#$AAAA,d1
		beq		3f
		cmpi.w		#$8000,d1
		beq		4f
		cmpi.w		#$5555,d1
		beq		5f
		cmpi.w		#$4000,d1
		beq		6f

		move.l		d1,d2
		lsl.l		#5,d2			* 16bit PCM
		move.l		d2,d3
		add.l		d2,d2
		add.l		d3,d2			* d2.l = CH_PITCH*96
		clr.w		d2
		swap.w		d2
		addq.l		#1,d2
		add.l		d2,d2			* ここがポイント

		lea.l		PCM16_low_tbl(pc),a0
		move.l		a0,CH_CNVADR_BASE(a5)
		move.w		sr,d3
		ori.w		#$0700,sr
		move.l		#PCM16_low,CH_JMP_ADR(a5)
		move.l		(a0,d4.w),CH_JMP_ADR2(a5)	* PCM16 低音変換
		move.l		d1,CH_PITCH(a5)
		move.l		d2,CH_TPCNST(a5)
		move.w		d3,sr
		rts

1:		move.l		d1,d2
		lsl.l		#5,d2			* 16bit PCM
		move.l		d2,d3
		add.l		d2,d2
		add.l		d3,d2			* d2.l = CH_PITCH*96
		clr.w		d2
		swap.w		d2
		addq.l		#1,d2
		add.l		d2,d2			* ここがポイント

		lea.l		PCM16_high_tbl(pc),a0
		move.l		a0,CH_CNVADR_BASE(a5)
		move.w		sr,d3
		ori.w		#$0700,sr
		move.l		#PCM16_high,CH_JMP_ADR(a5)
		move.l		(a0,d4.w),CH_JMP_ADR2(a5)	* PCM16 高音変換
		move.l		d1,CH_PITCH(a5)
		move.l		d2,CH_TPCNST(a5)
		move.w		d3,sr
		rts
2:		lea.l		PCM16_0101_tbl(pc),a0
		move.l		a0,CH_CNVADR_BASE(a5)
		move.w		sr,d3
		ori.w		#$0700,sr
		move.l		#PCM16_0101,CH_JMP_ADR(a5)
		move.l		(a0,d4.w),CH_JMP_ADR2(a5)	* PCM16 15.6kHz
		move.w		d3,sr
		rts
3:		lea.l		PCM16_0203_tbl(pc),a0
		move.l		a0,CH_CNVADR_BASE(a5)
		move.w		sr,d3
		ori.w		#$0700,sr
		move.l		#PCM16_0203,CH_JMP_ADR(a5)
		move.l		(a0,d4.w),CH_JMP_ADR2(a5)	* PCM16 10.4kHz
		move.w		d3,sr
		rts
4:		lea.l		PCM16_0102_tbl(pc),a0
		move.l		a0,CH_CNVADR_BASE(a5)
		move.w		sr,d3
		ori.w		#$0700,sr
		move.l		#PCM16_0102,CH_JMP_ADR(a5)
		move.l		(a0,d4.w),CH_JMP_ADR2(a5)	* PCM16 7.8kHz
		move.w		d3,sr
		rts
5:		lea.l		PCM16_0103_tbl(pc),a0
		move.l		a0,CH_CNVADR_BASE(a5)
		move.w		sr,d3
		ori.w		#$0700,sr
		move.l		#PCM16_0103,CH_JMP_ADR(a5)
		move.l		(a0,d4.w),CH_JMP_ADR2(a5)	* PCM16 5.2kHz
		move.w		d3,sr
		rts
6:		lea.l		PCM16_0104_tbl(pc),a0
		move.l		a0,CH_CNVADR_BASE(a5)
		move.w		sr,d3
		ori.w		#$0700,sr
		move.l		#PCM16_0104,CH_JMP_ADR(a5)
		move.l		(a0,d4.w),CH_JMP_ADR2(a5)	* PCM16 3.8kHz
		move.w		d3,sr
		rts

CALC_TPCNST8:	moveq.l		#0,d0			* 戻り値クリア
		move.w		CH_VOL_OFFS(a5),d4

		cmpi.l		#$0001_0000,d1
		bhi		1f
		beq		2f
		cmpi.w		#$AAAA,d1
		beq		3f
		cmpi.w		#$8000,d1
		beq		4f
		cmpi.w		#$5555,d1
		beq		5f
		cmpi.w		#$4000,d1
		beq		6f

		move.l		d1,d2
		lsl.l		#5,d2			* 8bit PCM
		move.l		d2,d3
		add.l		d2,d2
		add.l		d3,d2			* d2.l = CH_PITCH*96
		clr.w		d2
		swap.w		d2
		addq.l		#1,d2

		lea.l		PCM8_low_tbl(pc),a0
		move.l		a0,CH_CNVADR_BASE(a5)
		move.w		sr,d3
		ori.w		#$0700,sr
		move.l		#PCM8_low,CH_JMP_ADR(a5)
		move.l		(a0,d4.w),CH_JMP_ADR2(a5)	* PCM8 低音変換
		move.l		d1,CH_PITCH(a5)
		move.l		d2,CH_TPCNST(a5)
		move.w		d3,sr
		rts

1:		move.l		d1,d2
		lsl.l		#5,d2			* 8bit PCM
		move.l		d2,d3
		add.l		d2,d2
		add.l		d3,d2			* d2.l = CH_PITCH*96
		clr.w		d2
		swap.w		d2
		addq.l		#1,d2

		lea.l		PCM8_high_tbl(pc),a0
		move.l		a0,CH_CNVADR_BASE(a5)
		move.w		sr,d3
		ori.w		#$0700,sr
		move.l		#PCM8_high,CH_JMP_ADR(a5)
		move.l		(a0,d4.w),CH_JMP_ADR2(a5)	* PCM8 高音変換
		move.l		d1,CH_PITCH(a5)
		move.l		d2,CH_TPCNST(a5)
		move.w		d3,sr
		rts
2:		lea.l		PCM8_0101_tbl(pc),a0
		move.l		a0,CH_CNVADR_BASE(a5)
		move.w		sr,d3
		ori.w		#$0700,sr
		move.l		#PCM8_0101,CH_JMP_ADR(a5)
		move.l		(a0,d4.w),CH_JMP_ADR2(a5)	* PCM8 15.6kHz
		move.w		d3,sr
		rts
3:		lea.l		PCM8_0203_tbl(pc),a0
		move.l		a0,CH_CNVADR_BASE(a5)
		move.w		sr,d3
		ori.w		#$0700,sr
		move.l		#PCM8_0203,CH_JMP_ADR(a5)
		move.l		(a0,d4.w),CH_JMP_ADR2(a5)	* PCM8 10.4kHz
		move.w		d3,sr
		rts
4:		lea.l		PCM8_0102_tbl(pc),a0
		move.l		a0,CH_CNVADR_BASE(a5)
		move.w		sr,d3
		ori.w		#$0700,sr
		move.l		#PCM8_0102,CH_JMP_ADR(a5)
		move.l		(a0,d4.w),CH_JMP_ADR2(a5)	* PCM8 7.8kHz
		move.w		d3,sr
		rts
5:		lea.l		PCM8_0103_tbl(pc),a0
		move.l		a0,CH_CNVADR_BASE(a5)
		move.w		sr,d3
		ori.w		#$0700,sr
		move.l		#PCM8_0103,CH_JMP_ADR(a5)
		move.l		(a0,d4.w),CH_JMP_ADR2(a5)	* PCM8 5.2kHz
		move.w		d3,sr
		rts
6:		lea.l		PCM8_0104_tbl(pc),a0
		move.l		a0,CH_CNVADR_BASE(a5)
		move.w		sr,d3
		ori.w		#$0700,sr
		move.l		#PCM8_0104,CH_JMP_ADR(a5)
		move.l		(a0,d4.w),CH_JMP_ADR2(a5)	* PCM8 3.8kHz
		move.w		d3,sr
		rts

CALC_TPCNSTNO:	move.l		#NO_PCM,CH_JMP_ADR(a5)	* データ無しの場合
		rts

*===============================================================
* func_05xx	: PCM 音量設定
* call		: d1.b = 音量
*			 64 が原音量
*		  a5.l = チャンネルワークアドレス
* return	: 特に無し
*===============================================================


func_05xx:	movea.l		CH_CNVADR_BASE(a5),a0
		andi.w		#$007f,d1			* NO_PCMの場合は機能しないので気にしない
		move.w		d1,CH_USER_VOL(a5)
		add.w		d1,d1
		move.w		func_05xx_tbl(pc,d1.w),d0	* 音量を実際値に変換
		move.w		d0,CH_VOL(a5)			* ワークに保存
		beq		func_05xx_Vx0			* 0だったら専用ルーチンへ

		lea.l		func_05xx_scantbl(pc),a1
		moveq.l		#-4,d1
		moveq.l		#16-1,d2
@@:		addq.w		#4,d1
		cmp.w		(a1)+,d0			* 高速化できる音量か調べる
		beq		@f
		dbra		d2,@b

		move.w		#16*4,CH_VOL_OFFS(a5)		* 掛け算を使う音量である
		move.l		16*4(a0),CH_JMP_ADR2(a5)
		moveq.l		#0,d0
		rts

func_05xx_Vx0:	move.w		#17*4,CH_VOL_OFFS(a5)		* 音量0である
		move.l		17*4(a0),CH_JMP_ADR2(a5)
		moveq.l		#0,d0
		rts

@@:		move.w		d1,CH_VOL_OFFS(a5)
		move.l		(a0,d1.w),CH_JMP_ADR2(a5)	* 音量計算の専用ルーチンへ
		moveq.l		#0,d0
		rts

func_05xx_tbl:	.dc.w		  16,  17,  18,  19,  20,  21,  22,  23	* 実際に掛ける値(n/128)
		.dc.w		  24,  25,  26,  27,  28,  29,  30,  31
		.dc.w		  32,  33,  34,  35,  36,  37,  38,  39
		.dc.w		  40,  41,  42,  43,  44,  45,  46,  47
		.dc.w		  48,  50,  52,  54,  56,  58,  60,  62
		.dc.w		  64,  66,  68,  70,  72,  74,  76,  78
		.dc.w		  80,  82,  84,  86,  88,  90,  92,  94
		.dc.w		  96, 100, 104, 108, 112, 116, 120, 124
		.dc.w		 128, 132, 136, 140, 144, 148, 152, 156
		.dc.w		 160, 164, 168, 172, 176, 180, 184, 188
		.dc.w		 192, 200, 208, 216, 224, 232, 240, 248
		.dc.w		 256, 264, 272, 280, 288, 296, 304, 312
		.dc.w		 320, 328, 336, 344, 352, 360, 368, 376
		.dc.w		 384, 400, 416, 432, 448, 464, 480, 496
		.dc.w		 512, 528, 544, 560, 576, 592, 608, 624
		.dc.w		 640, 656, 672, 688, 704, 720, 736, 752

func_05xx_scantbl:
		.dc.w		  16,  24,  32,  40,  48,  64,  80,  96
		.dc.w		 128, 160, 192, 256, 320, 384, 512, 640


*===============================================================
* func_06xx	: PCM PAN 設定
* call		: d1.b =   0:無音 1:左 2:右 3:中央	(3段階指定)
*			 $80 + 0(左)～64(中央)～127(右) (128段階指定)
*		  a5.l = チャンネルワークアドレス
* return	: 特に無し
*===============================================================

func_06xx:	move.b		d1,CH_PAN+1(a5)			* PAN保存
		bmi		1f
		andi.w		#$0003,d1
		move.b		pan_tbl3-mpw(a6,d1.w),ADPCM_pan-mpw(a6)
		st.b		pan_set_flag-mpw(a6)
		moveq.l		#0,d0
		rts
1:		andi.w		#$007f,d1
		lsr.w		#5,d1
		move.b		pan_tbl128-mpw(a6,d1.w),ADPCM_pan-mpw(a6)
		st.b		pan_set_flag-mpw(a6)
		moveq.l		#0,d0
		rts

*===============================================================
* func_07xx	: PCM 種類変更
* call		: d1.b = PCM 種類 
*			 ($ff = ADPCM / $00 = 無し / $01 = 16bitPCM / $02 = 8bitPCM)
*		  a5.l = チャンネルワークアドレス
* return	: 特に無し
*===============================================================

func_07xx:	cmp.b		CH_PCM_KIND(a5),d1
		beq		func_07xx_end

		move.b		d1,CH_PCM_KIND(a5)
		bmi		f07xx_ADPCM
		beq		f07xx_NOPCM
		sub.b		#$02,d1
		bmi		f07xx_PCM16

f07xx_PCM8:	move.l		#CALC_TPCNST8,CH_TPCNST_CADR(a5)	* アドレス増分計算アドレス
		move.w		CH_USER_NOTE(a5),d1
		bra		func_04xx_x		* 音程再設定

f07xx_PCM16:	btst.b		#0,CH_LPEND_ADR+3(a5)
		beq		1f
		add.l		#1,CH_LPEND_ADR(a5)			* LP終端を偶数に合わせる
1:		move.l		#CALC_TPCNST16,CH_TPCNST_CADR(a5)	* アドレス増分計算アドレス
		move.w		CH_USER_NOTE(a5),d1
		bra		func_04xx_x		* 音程再設定

f07xx_ADPCM:	move.l		#CALC_TPCNSTADP,CH_TPCNST_CADR(a5)	* アドレス増分計算アドレス
		move.w		CH_USER_NOTE(a5),d1
		bra		func_04xx_x		* 音程再設定

f07xx_NOPCM:	move.l		#CALC_TPCNSTNO,CH_TPCNST_CADR(a5)	* アドレス増分計算アドレス
		move.l		#NO_PCM,CH_JMP_ADR(a5)	* データ無しの場合

func_07xx_end:	rts

*===============================================================
* func_10xx	: PCM 効果音再生
* call		: d1.l = PCM種類(-1:ADPCM 0:データ無し 1:16bitPCM 2:8bitPCM) * $01000000
*			+音量(現在は64のみ指定可) * $010000
*			+再生周波数(0:3.9kHz 1:5.2kHz 2:7.8kHz 3:10.4kHz 4:15.6kHz 5:20.4kHz 6:31.2kHz) * $0100
*			+PAN(0-3 / $80+0-126 / $ff)
*		  d2.l = PCM長さ(バイト数)
*		  a1.l = PCMアドレス
*		  a5.l = チャンネルワークアドレス
* return	: 特に無し
*===============================================================

func_10xx:
		clr.b		EFCT_PLAY_FLAG(a5)	* PLAY_FLAG OFF

		move.l		a1,EFCT_PCM_ADR(a5)	* アドレス保存
		move.l		d2,EFCT_PCM_LEN(a5)	* 長さ保存
		beq		func_13xx		* 長さ0 = keyoff

* PAN
		move.b		d1,EFCT_PAN+1(a5)	* PAN 保存
		move.b		d1,d0
		bmi		1f
		andi.w		#$0003,d0		* PAN 3段階指定
		move.b		pan_tbl3-mpw(a6,d0.w),ADPCM_pan-mpw(a6)
		bra		2f
1:		andi.w		#$007f,d0		* PAN 128段階指定
		lsr.w		#5,d0
		move.b		pan_tbl128-mpw(a6,d0.w),ADPCM_pan-mpw(a6)
2:		st.b		pan_set_flag-mpw(a6)

		* FRQ
		move.w		d1,d0
		lsr.w		#8,d0
		cmpi.b		#$06+1,d0
		bcc		func_10xx_err
		move.b		d0,EFCT_FRQ+1(a5)	* FRQ保存
		add.w		d0,d0
		add.w		d0,d0
		add.w		frq_offset-mpw(a6),d0	* 高周波数対応

@@:		swap.w		d1
		lsr.w		#8,d1
		tst.b		d1
		bmi		1f			* ADPCM
		bhi		2f			* 16/8 bit PCM
		bra		func_10xx_err		* 終わり
1:		move.b		d1,EFCT_PCM_KIND(a5)
		move.l		AtoP_EFCT_tbl-mpw(a6,d0.w),EFCT_JMP_ADR(a5)
		move.l		#AtoP_tbl,EFCT_AtoP_X(a5)
		clr.w		EFCT_AtoP_Y(a5)
		bra		4f
2:		move.b		d1,EFCT_PCM_KIND(a5)
		subq.b		#1,d1
		bne		3f
		move.l		PCM16_EFCT_tbl-mpw(a6,d0.w),EFCT_JMP_ADR(a5)
		bra		4f
3:		move.l		PCM8_EFCT_tbl-mpw(a6,d0.w),EFCT_JMP_ADR(a5)

4:		clr.b		EFCT_PLAY_MODE(a5)	* 通常再生
		st.b		EFCT_PLAY_FLAG(a5)	* PLAY_FLAG ON

		bra		func_00xx_DMA_start

func_10xx_err:	move.l		#NO_PCM,EFCT_JMP_ADR(a5)	* PCM種類 = none
		moveq.l		#-1,d0			* 異状終了コード
		rts

*===============================================================
* func_13xx	: PCM 効果停止
* call		: 無し
* return	: 無し
*===============================================================

func_13xx:	clr.b		EFCT_PLAY_FLAG(a5)
		moveq.l		#0,d0
		rts


*===============================================================
* func_8000	: MPCM占有
* call		: a1.l = 占有するアプリケーション名の文字列アドレス
* return	: d0.l = 0	占有できた
*		       < 0	占有できなかった
*===============================================================
func_8000:	tst.b		(a1)
		beq		func_8000_err		* (a1.l)=null error!
		moveq.l		#0,d0
		move.b		mpcm_locked-mpw(a6),d0
		addq.b		#1,d0
		cmpi.b		#32+1,d0
		bcc		func_8000_err
		move.b		d0,mpcm_locked-mpw(a6)

		lea.l		mplock_app_name-mpw(a6),a0	* a0.l = app name buffer address
		moveq.l		#32-1,d0
1:		tst.b		(a0)
		beq		@f
		lea.l		32(a0),a0
		dbra		d0,1b
@@:
		moveq.l		#32-1,d0
1:		move.b		(a1)+,(a0)+
		dbeq		d0,1b

		tst.w		d0
		bpl		1f
		clr.b		-(a0)			* null terminate
1:		moveq.l		#0,d0
		rts

func_8000_err:	moveq.l		#-1,d0
		rts

*===============================================================
* func_8001	: MPCM占有解除
* call		: a1.l = 占有解除するアプリケーション名の文字列アドレス
* return	: d0.l = 0	占有解除できた
*		       < 0	占有されていなかった
*===============================================================
func_8001:	move.b		mpcm_locked-mpw(a6),d0
		subq.b		#1,d0
		bcs		func_8001_err

		lea.l		mplock_app_name-mpw(a6),a0
		moveq.l		#32-1,d0
1:		tst.b		(a0)
		beq		3f
		movea.l		a1,a2
		movea.l		a0,a3
		moveq.l		#32-1,d1
2:		move.b		(a2)+,d2
		move.b		(a3)+,d3
		or.b		d2,d3
		beq		@f			* 0.b 同志なら比較終了
		cmp.b		d2,d3
		dbne		d1,2b			* 32文字いくか違うのにあたるまで
3:		lea.l		32(a0),a0
		dbra		d0,1b
		bra		func_8001_err		* 無いぞ！

@@:		clr.b		(a0)			* バッファ先頭をnull clear
		moveq.l		#1,d0
		sub.b		d0,mpcm_locked-mpw(a6)
		moveq.l		#0,d0
		rts
func_8001_err:	moveq.l		#-1,d0
		rts

*===============================================================
* func_8002	: MPCM初期化
* call		: 無し
* return	: 無し
*===============================================================

func_8002:	move.w		sr,d6
		ori.w		#$0700,sr		* 割り込み禁止

		bsr		init_channel_work	* 全チャンネルワーク初期化

		clr.b		ADPCM_SYSWORK.w		* IOCS 初期化

		move.w		frq_offset-mpw(a6),d0
		beq		2f
		cmpi.w		#4*2,d0
		beq		1f
		move.w		#$0203,d1		* ADPCM 7.8kHz
		bra		@f
1:		move.w		#$0403,d1		* ADPCM 15.6kHz
		bra		@f
2:		move.w		#$0603,d1		* ADPCM 31.2kHz
@@:		bsr		ADPCM_mode		* 周波数15.6kHz/PAN左右
		move.b		#$02,ADPCM+1		* ADPCM再生動作開始

		lea.l		DMA3,a0			* DMA 初期化
		move.b		#$04,SCR(a0)		* SCR clear
		move.b		#$10,DCCR(a0)		* CCR DMA停止割り込み無し
		move.b		#$80,DCR(a0)		* DCR clear
		move.b		#$02,OCR(a0)		* OCR clear
		move.b		#$01,CPR(a0)
		move.b		#$05,MFC(a0)
		move.b		#$05,DFC(a0)

		move.l		#dummy_ADPCM,MAR(a0)	* $88を通常出力
		move.l		#ADPCM+3,DAR(a0)	* ADPCM データレジスタ
		move.w		#8,MTC(a0)		* 8バイトだけ
		move.b		CSR(a0),CSR(a0)		* CSR all clear
		move.b		#$80,DCCR(a0)		* DMA START/割り込み無し

		move.w		d6,sr
		moveq.l		#0,d0
		rts


init_channel_work:

* 		演奏ワーク初期化

		lea.l		ch0_work(pc),a5
		moveq.l		#CH_MAX-1,d0			* d0.l = loop counter
		moveq.l		#1,d1				* d1.l = channel mask bit

@@:		clr.b		CH_KEY_STAT(a5)			* KEY STATUS	: non
		clr.b		CH_PLAY_FLAG(a5)		* CH PLAY	: non

		clr.b		CH_PCM_KIND(a5)				* PCM KIND	: NO DATA
		move.l		#NO_PCM,CH_JMP_ADR(a5)			* 飛び先
		move.l		#CALC_TPCNSTNO,CH_TPCNST_CADR(a5)	* アドレス増分計算アドレス
		move.l		#AtoP_0101_tbl,CH_CNVADR_BASE(a5)	* 変換ルーチンアドレステーブルのベースアドレス


		move.l		#func_04xx_01_01,CH_PITCH_CADR(a5)	* 音程変換関係
		move.l		#$0001_0000,CH_ORG_PITCH(a5)
		move.l		#$0001_0000,CH_PITCH(a5)
		clr.w		CH_PITCH_CTR(a5)
		clr.w		CH_ORG_NOTE(a5)
		clr.w		CH_USER_NOTE(a5)
		move.b		#$80,CH_USER_FRQ(a5)			* 周波数はなにもない

		move.l		#CALC_TPCNSTADP,CH_TPCNST_CADR(a5)	* トラップ関係
		move.l		#$0000_0001*48,CH_TPCNST(a5)
		move.l		#AtoP_END,CH_TRAP_ROUTINE(a5)		* トラップ時の処理アドレス

		move.l		#$0000_0001,CH_LPTIME(a5)		* ループ無し
		move.l		#$0000_0001,CH_LPTIME_CTR(a5)

		move.w		#64,CH_VOL(a5)				* 音量
		move.w		#8*4,CH_VOL_OFFS(a5)			* 専用ルーチンオフセット
		move.w		#64,CH_PAN(a5)				* PAN

		move.l		#AtoP_tbl,CH_AtoP_X(a5)		* ADPCM->PCM変換X
		clr.w		CH_AtoP_Y(a5)			* ADPCM->PCM変換Y
		clr.w		CH_LAST_PCM(a5)			* LAST PCM
		st.b		CH_ODDEVEN(a5)			* 処理してたADPCMの偶・奇
		move.w		#$0040,CH_PAN(a5)		* PAN (128段階)
		move.l		d1,CH_CHANNEL_MASK(a5)		* チャンネルマスクビットパターン

		add.l		d1,d1				* マスクをシフト
		lea.l		CH_WORK_SIZE(a5),a5
		dbra		d0,@b

*		効果音&IOCSワーク初期化

		moveq.l		#EFCT_MAX+1-1,d0		* d0.l = ループカウンタ
		move.l		#$0080_0000,d1			* d3.l = チャンネルマスク
@@:		move.l		#NO_PCM,EFCT_JMP_ADR(a5)	* データ無し
		clr.l		EFCT_PCM_ADR(a5)		* PCMアドレス
		clr.l		EFCT_PCM_LEN(a5)		* PCM長さ
		clr.l		EFCT_CTBL_ADR(a5)		* チェーンテーブルアドレス
		clr.w		EFCT_CTBL_N(a5)			* チェーンテーブルの数
		move.l		#AtoP_tbl,EFCT_AtoP_X(a5)	* ADPCM->PCM変換X
		clr.w		EFCT_AtoP_Y(a5)			* ADPCM->PCM変換Y
		move.l		d1,EFCT_CH_MASK(a5)		* チャンネルマスク
		clr.b		EFCT_PLAY_FLAG(a5)		* PLAY FLAG クリア
		clr.b		EFCT_PLAY_MODE(a5)		* PLAY MODE 通常

		add.l		d1,d1				* マスクをシフト
		lea.l		EFCT_WORK_SIZE(a5),a5
		dbra		d0,@b

*		割り込みワーク初期化

		move.l		#PtoA_tbl,PtoA_X
		clr.w		PtoA_Y
		st.b		ADPCM_out_flag-mpw(a6)
		clr.b		ADPCM_pan-mpw(a6)
		clr.l		play_flag-mpw(a6)
		clr.b		pan_set_flag-mpw(a6)
		move.w		#-1,mpcm_nest			* 多重割り込み回数
		move.w		#-100,overload_ctr		* 過負荷時のリトライ回数
		move.w		#$0008,efct_poly-mpw(a6)	* 効果音8音まで発声

.ifdef	FCTRACE
		move.l		#TEXT_RAM+$40000,fc_logadr-mpw(a6)	* funcログ書き込みアドレス
.endif

		rts

*===============================================================
* func_8003	: DMA割り込み中のMPU/MFPのマスク設定
* call		: d1.l = マスクデータ
*		  ＜0 割り込みマスク収得
*		  ≧0 割り込みマスク設定
*
*		  ビット18～16 : MPU 割り込みレベル(0～7 推奨3以上)
*			15～8  : MFP 割り込みマスクA (IMRA)
*			 7～0  : MFP 割り込みマスクB (IMRB)
*		  ビット15～0では、1で割り込み前と同じ状態になる。
*		  よーするにMFPのIMRA,IMRBとANDをとっている。
*
* return	: d0.l = 変更前の割り込みマスク
*			 関係ないビット(31～19)は0になる。
*===============================================================

func_8003:	move.w		MPU_mask-mpw(a6),d0
		lsr.w		#8,d0
		swap.w		d0
		move.b		IMR_mask+1-mpw(a6),d0
		lsl.w		#8,d0
		move.b		IMR_mask+3-mpw(a6),d0	* d0.l = 元のマスク

		tst.l		d1
		bmi		@f

		move.w		sr,d0
		ori.w		#$0700,sr		* 割り込み禁止
		move.b		d1,IMR_mask+3-mpw(a6)	* mask設定
		lsr.w		#8,d1
		move.b		d1,IMR_mask+1-mpw(a6)
		swap.w		d1
		lsl.w		#8,d1
		andi.w		#$0700,d1
		move.w		d1,MPU_mask-mpw(a6)
		move.w		d0,sr
@@:		rts

*===============================================================
* func_8004	: MPCM動作モード設定
* call		: d1.l = 設定データ
*		  ＜0 モード収得
*		  ≧0 モード設定
*
* return	: d0.l = 動作モード
*			 関係ないビット(31～2)は0になる。
*===============================================================
func_8004:	tst.l		d1
		bmi		func_8004_get

*		move.l		d1,mpcm_mode-mpw(a6)
		rts

func_8004_get:	move.l		mpcm_mode-mpw(a6),d0
		rts


*===============================================================
* func_8005	: MPCM音量マップ設定
* call		: d1.l = 設定モード(0:128段階 / 1:16段階 / $ff:ユーザー設定)
*		  a1.l = 音量テーブルアドレス(ユーザー設定時)
* return	: 無し
*===============================================================
func_8005:	tst.b		volume_mode-mpw(a6)
		bne		func_8005_end			* 音量固定モード
		tst.l		d1
		bmi		func_8005_user			* ユーザー定義へ
		beq		1f
		lea.l		func_8005_tbl1(pc),a1		* 16段階テーブル
		bra		func_8005_user
1:		lea.l		func_8005_tbl2(pc),a1		* 128段階テーブル
func_8005_user:	lea.l		func_05xx_tbl(pc),a0
		moveq.l		#128/2-1,d0
@@:		move.l		(a1)+,(a0)+
		dbra		d0,@b
func_8005_end:	rts

func_8005_tbl1:	.dc.w		  16,  16,  16,  16,  16,  16,  16,  16	* 音量16段階
		.dc.w		  24,  24,  24,  24,  24,  24,  24,  24
		.dc.w		  32,  32,  32,  32,  32,  32,  32,  32
		.dc.w		  40,  40,  40,  40,  40,  40,  40,  40
		.dc.w		  48,  48,  48,  48,  48,  48,  48,  48
		.dc.w		  64,  64,  64,  64,  64,  64,  64,  64
		.dc.w		  80,  80,  80,  80,  80,  80,  80,  80
		.dc.w		  96,  96,  96,  96,  96,  96,  96,  96
		.dc.w		 128, 128, 128, 128, 128, 128, 128, 128
		.dc.w		 160, 160, 160, 160, 160, 160, 160, 160
		.dc.w		 192, 192, 192, 192, 192, 192, 192, 192
		.dc.w		 256, 256, 256, 256, 256, 256, 256, 256
		.dc.w		 320, 320, 320, 320, 320, 320, 320, 320
		.dc.w		 384, 384, 384, 384, 384, 384, 384, 384
		.dc.w		 512, 512, 512, 512, 512, 512, 512, 512
		.dc.w		 640, 640, 640, 640, 640, 640, 640, 640

func_8005_tbl2:	.dc.w		  16,  17,  18,  19,  20,  21,  22,  23	* 音量128段階
		.dc.w		  24,  25,  26,  27,  28,  29,  30,  31
		.dc.w		  32,  33,  34,  35,  36,  37,  38,  39
		.dc.w		  40,  41,  42,  43,  44,  45,  46,  47
		.dc.w		  48,  50,  52,  54,  56,  58,  60,  62
		.dc.w		  64,  66,  68,  70,  72,  74,  76,  78
		.dc.w		  80,  82,  84,  86,  88,  90,  92,  94
		.dc.w		  96, 100, 104, 108, 112, 116, 120, 124
		.dc.w		 128, 132, 136, 140, 144, 148, 152, 156
		.dc.w		 160, 164, 168, 172, 176, 180, 184, 188
		.dc.w		 192, 200, 208, 216, 224, 232, 240, 248
		.dc.w		 256, 264, 272, 280, 288, 296, 304, 312
		.dc.w		 320, 328, 336, 344, 352, 360, 368, 376
		.dc.w		 384, 400, 416, 432, 448, 464, 480, 496
		.dc.w		 512, 528, 544, 560, 576, 592, 608, 624
		.dc.w		 640, 656, 672, 688, 704, 720, 736, 752

*===============================================================
* func_8006	: 効果音発声数設定
* call		: d1.l = 効果音発声数(0-8)
*			 0 の時は最大数指定とみなす
* return	: 無し
*===============================================================
func_8006:	cmpi.w		#EFCT_MAX+1,d1
		bcc		@f
		subq.w		#1,d1
		bpl		1f
		moveq.l		#EFCT_MAX,d1				* 0なら最大
1:		move.w		d1,efct_poly-mpw(a6)
@@:		rts




*===============================================================
* func_8010	: MPCMのチャンネルワークアドレス問い合わせ
* call		: 無し
* return	: d0.l = 先頭アドレス
*		  ワークのサイズは1チャンネルにつき128バイト。
*		  チャンネル0から15まで順に並んでいる。
*===============================================================
func_8010:	move.l		#ch0_work,d0
		rts

*===============================================================
* func_8011	: MPCMのシステムワークアドレス問い合わせ
* call		: 無し
* return	: d0.l = 先頭アドレス
*		  下手にいじると暴走するので注意して使ってください。
*===============================================================
func_8011:	move.l		#mpw,d0
		rts

*===============================================================
* func_8012	: MPCMのチャンネル指定ファンクションの
*		　処理ルーチンアドレス問い合わせ
* call		: 無し
* return	: d0.l = アドレステーブルの先頭アドレス
*		  func_00xxから番号順に並んでいる
*===============================================================
func_8012:	move.l		#trap1_jmp_tbl0,d0
		rts

*===============================================================
* func_8013	: MPCMの全体ファンクションの処理ルーチンアドレス
*		　問い合わせ
* call		: 無し
* return	: d0.l = アドレステーブルの先頭アドレス
*		  func_8000から番号順に並んでいる
*===============================================================
func_8013:	move.l		#trap1_jmp_tbl1,d0
		rts


*▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽
*
*		IOCSコール処理
*
*△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△

*===============================================================
* IOCS	_ADPCMOUT
* call		: d0.l = IOCSコール番号
*		  d1.w = サンプリング周波数 * 256 + PAN
*		  d2.l = データ長さ
*		  a1.l = データアドレス
*===============================================================

mpcm_iocs_60:	movem.l		d1/d2/a0/a5/a6,-(sp)

		move.w		sr,d0
		ori.w		#$0700,sr		* 割り込み禁止
		btst.b		#2,ADPCM_SYSWORK.w	* 録音中?
		beq		@f
		move.w		d0,sr			* 録音中ならこのコールを無視
		movem.l		(sp)+,d1/d2/a0/a5/a6
		rts

@@:		move.b		#02,ADPCM_SYSWORK.w	* IOCS $60 実行中

		lea.l		IOCS_work(pc),a5
		lea.l		mpw(pc),a6
		clr.b		EFCT_PLAY_FLAG(a5)	* 演奏中止

		move.w		d0,sr

		move.l		a1,EFCT_PCM_ADR(a5)	* アドレス保存
		move.l		d2,EFCT_PCM_LEN(a5)	* 長さ保存

		move.w		d1,d2
		andi.w		#$0003,d2
		move.b		pan_tbl3-mpw(a6,d2.w),ADPCM_pan-mpw(a6)	* PAN変換/保存
		st.b		pan_set_flag-mpw(a6)	* PAN設定

		clr.b		d1
		lsr.w		#6,d1
		add.w		frq_offset-mpw(a6),d1
		move.l		AtoP_EFCT_tbl-mpw(a6,d1.w),EFCT_JMP_ADR(a5)

		move.l		#AtoP_tbl,EFCT_AtoP_X(a5)
		clr.w		EFCT_AtoP_Y(a5)

		clr.b		EFCT_PLAY_MODE(a5)	* 通常再生
		st.b		EFCT_PLAY_FLAG(a5)	* PLAY_FLAG ON

		tst.l		play_flag-mpw(a6)	* 今演奏中？
		bne		@f
		bsr		func_00xx_DMA_start		* DMA再起動
@@:		movem.l		(sp)+,d1/d2/a0/a5/a6
		rts

*===============================================================
* IOCS	_ADPCMINP
* call		: d0.l = IOCSコール番号
*		  d1.w = サンプリング周波数 * 256 + PAN
*		  d2.l = データ長さ
*		  a1.l = データアドレス
*===============================================================


mpcm_iocs_61:	movem.l		d2/a0/a6,-(sp)		* IOCS _ADPCMINP

		lea.l		mpw(pc),a6

		move.w		sr,d0
		ori.w		#$0700,sr		* 割り込み禁止

		tst.b		ADPCM_SYSWORK.w		* 他のIOCSコール実行中?
		bne		@f
		tst.l		play_flag-mpw(a6)	* MPCM演奏中?
		bne		@f

		move.b		#$04,ADPCM_SYSWORK.w	* $61 実行中

		bsr		ADPCM_mode		* ADPCMの周波数/PAN設定(d1.wで)

		lea.l		DMA3,a0			* DMA初期化(録音用)
		move.w		#$8082,DCR(a0)		* I/O -> メモリ転送
		move.b		#$04,SCR(a0)
		move.b		#$01,CPR(a0)
		move.b		#$05,MFC(a0)
		move.b		#$05,DFC(a0)
		move.l		a1,MAR(a0)		* 録音メモリのアドレス
		move.l		#ADPCM+3,DAR(a0)	* ADPCM データレジスタ

		cmpi.l		#$0000_ff00,d2
		bhi		1f			* d2.l > ff00なら
		st.b		IOCS_REC_LEN-mpw(a6)	* 残り長さをマイナスにしておく
		move.w		d2,MTC(a0)		* 転送長をDMAに設定
		move.b		CSR(a0),CSR(a0)		* CSR all clear
		move.b		#$88,DCCR(a0)		* 通常動作/割り込み有り
		move.b		#$04,ADPCM+1		* ADPCM recording start
		bra		@f

1:		sub.l		#$0000_ff00,d2
		move.w		#$ff00,MTC(a0)		* 転送長をDMAに設定
		move.b		CSR(a0),CSR(a0)		* CSR all clear
		move.b		#$88,DCCR(a0)		* 通常動作/割り込み有り
		move.b		#$04,ADPCM+1		* ADPCM recording start

		adda.l		#$0000_ff00,a1		* 次のアドレス
		move.l		a1,BAR(a0)

		cmpi.l		#$0000_ff00,d2
		bhi		1f			* d2.l > $ff00なら
		clr.l		IOCS_REC_LEN-mpw(a6)
		move.w		d2,BTC(a0)		* 残り長さ
		move.b		#$05,BFC(a0)
		move.b		CSR(a0),CSR(a0)		* CSR all clear
		move.b		#$48,DCCR(a0)		* 継続動作/転送終了割込あり
		bra		@f

1:		sub.l		#$0000_ff00,d2
		move.l		d2,IOCS_REC_LEN-mpw(a6)	* 残り長さ保存
		move.w		#$ff00,BTC(a0)
		move.b		#$05,BFC(a0)
		move.b		CSR(a0),CSR(a0)		* CSR all clear
		move.b		#$48,DCCR(a0)		* 継続動作/転送終了割込あり

@@:		move.w		d0,sr			* sr 戻す
		movem.l		(sp)+,d2/a0/a6
		rts

*===============================================================
* IOCS	_ADPCMAOT
* call		: d0.l = IOCSコール番号
*		  d1.w = サンプリング周波数 * 256 + PAN
*		  d2.l = 出力データチェーンテーブル個数
*		  a1.l = チェーンテーブルアドレス
*===============================================================

mpcm_iocs_62:	movem.l		d1/d2/a0/a1/a5/a6,-(sp)	* IOCS	_ADPCMAOT

		move.w		sr,d0
		ori.w		#$0700,sr		* 割り込み禁止
		btst.b		#2,ADPCM_SYSWORK.w	* 録音中?
		beq		@b
		move.w		d0,sr
		movem.l		(sp)+,d1/d2/a0/a1/a5/a6
		rts

@@:		move.b		#$12,ADPCM_SYSWORK.w	* IOCS $62 実行中

		lea.l		IOCS_work(pc),a5
		lea.l		mpw(pc),a6
		clr.b		EFCT_PLAY_FLAG(a5)	* 演奏中止

		move.w		d0,sr

		move.l		d2,EFCT_CTBL_N(a5)
		move.l		(a1)+,EFCT_PCM_ADR(a5)
		clr.w		EFCT_PCM_LEN(a5)
		move.w		(a1)+,EFCT_PCM_LEN+2(a5)
		move.l		a1,EFCT_CTBL_ADR(a5)

		move.w		d1,d2
		andi.w		#$0003,d2
		move.b		pan_tbl3-mpw(a6,d2.w),ADPCM_pan-mpw(a6)	* PAN変換/保存
		st.b		pan_set_flag-mpw(a6)

		clr.b		d1
		lsr.w		#6,d1
		add.w		frq_offset-mpw(a6),d1
		move.l		AtoP_EFCT_tbl-mpw(a6,d1.w),EFCT_JMP_ADR(a5)

		move.l		#AtoP_tbl,EFCT_AtoP_X(a5)
		clr.w		EFCT_AtoP_Y(a5)

		move.b		#$01,EFCT_PLAY_MODE(a5)	* アレイチェーン
		st.b		EFCT_PLAY_FLAG(a5)

		tst.l		play_flag-mpw(a6)
		bne		@f
		bsr		func_00xx_DMA_start
@@:		movem.l		(sp)+,d1/d2/a0/a1/a5/a6
		rts

*===============================================================
* IOCS	_ADPCMAIN
* call		: d0.l = IOCSコール番号
*		  d1.w = サンプリング周波数 * 256 + PAN
*		  d2.l = 出力データチェーンテーブル個数
*		  a1.l = チェーンテーブルアドレス
*===============================================================

mpcm_iocs_63:	movem.l		d2/a0/a6,-(sp)		* IOCS _ADPCMAIN

		lea.l		mpw(pc),a6

		move.w		sr,d0
		ori.w		#$0700,sr		* 割り込み禁止

		tst.b		ADPCM_SYSWORK.w		* 他のIOCSコール実行中?
		bne		@f
		tst.l		play_flag-mpw(a6)	* MPCM演奏中?
		bne		@f

		move.b		#$14,ADPCM_SYSWORK.w	* $63 実行中

		move.w		d0,sr

		bsr		ADPCM_mode		* ADPCMの周波数/PAN設定(d1.wで)

		lea.l		DMA3,a0			* DMA初期化(録音用)
		move.w		#$8082,DCR(a0)		* I/O -> メモリ転送
		move.b		#$04,SCR(a0)
		move.b		#$01,CPR(a0)
		move.b		#$05,MFC(a0)
		move.b		#$05,DFC(a0)
		move.l		(a1)+,MAR(a0)		* 録音メモリのアドレス
		move.l		#ADPCM+3,DAR(a0)	* ADPCM データレジスタ
		move.w		(a1)+,d0
		andi.w		#$ff00,d0		* $ff00以上は転送しないよ
		move.w		d0,MTC(a0)		* 転送長をDMAに設定
		move.b		CSR(a0),CSR(a0)		* CSR all clear
		move.b		#$88,DCCR(a0)		* 通常動作/割り込み有り
		move.b		#$04,ADPCM+1		* ADPCM recording start

		sub.l		#1,d2			* テーブル1個しかない？
		beq		1f

		move.l		(a1)+,BAR(a0)		* 次のアドレス
		move.w		(a1)+,d0
		andi.w		#$ff00,d0		* $ff00以上は転送しないよ
		move.w		d0,BTC(a0)		* 残り長さ
		move.b		#$05,BFC(a0)
		move.b		CSR(a0),CSR(a0)		* CSR all clear
		move.b		#$48,DCCR(a0)		* 継続動作/転送終了割込あり

		sub.l		#1,d2			* テーブル個数-1

1:		move.l		a1,IOCS_REC_CTBL_ADR-mpw(a6)	* 次のテーブルアドレス
		move.l		d2,IOCS_REC_CTBL_N-mpw(a6)	* 残りテーブル

		bra		1f

@@:		move.w		d0,sr			* sr 戻す
1:		movem.l		(sp)+,d2/a0/a6
		rts

*===============================================================
* IOCS	_ADPCMLOT
* call		: d0.l = IOCSコール番号
*		  d1.w = サンプリング周波数 * 256 + PAN
*		  a1.l = アレイチェーンテーブルアドレス
*===============================================================

mpcm_iocs_64:	movem.l		d1/d2/a0/a1/a5/a6,-(sp)	* _ADPCMLOT

		move.w		sr,d0
		ori.w		#$0700,sr		* 割り込み禁止
		btst.b		#2,ADPCM_SYSWORK.w	* 録音中?
		beq		@f
		move.w		d0,sr
		movem.l		(sp)+,d1/d2/a0/a1/a5/a6
		rts

@@:		move.b		#$14,ADPCM_SYSWORK.w	* IOCS $64 実行中

		lea.l		IOCS_work(pc),a5
		lea.l		mpw(pc),a6
		clr.b		EFCT_PLAY_FLAG(a5)	* 演奏中止

		move.w		d0,sr

		move.l		(a1)+,EFCT_PCM_ADR(a5)
		clr.w		EFCT_PCM_LEN(a5)
		move.w		(a1)+,EFCT_PCM_LEN+2(a5)
		move.l		(a1),EFCT_CTBL_ADR(a5)

		move.w		d1,d2
		andi.w		#$0003,d2
		move.b		pan_tbl3-mpw(a6,d2.w),ADPCM_pan-mpw(a6)	* PAN変換/保存
		st.b		pan_set_flag-mpw(a6)

		clr.b		d1
		lsr.w		#6,d1
		add.w		frq_offset-mpw(a6),d1
		move.l		AtoP_EFCT_tbl-mpw(a6,d1.w),EFCT_JMP_ADR(a5)

		move.l		#AtoP_tbl,EFCT_AtoP_X(a5)
		clr.w		EFCT_AtoP_Y(a5)

		move.b		#$02,EFCT_PLAY_MODE(a5)	* リンクアレイチェーン
		st.b		EFCT_PLAY_FLAG(a5)	* 再生開始

		tst.l		play_flag-mpw(a6)
		bne		@f
		bsr		func_00xx_DMA_start
@@:		movem.l		(sp)+,d1/d2/a0/a1/a5/a6
		rts

*===============================================================
* IOCS	_ADPCMLIN
* call		: d0.l = IOCSコール番号
*		  d1.w = サンプリング周波数 * 256 + PAN
*		  a1.l = アレイチェーンテーブルアドレス
*===============================================================

mpcm_iocs_65:	movem.l		d2/a0/a6,-(sp)		* IOCS _ADPCMAIN

		lea.l		mpw(pc),a6

		move.w		sr,d0
		ori.w		#$0700,sr		* 割り込み禁止

		tst.b		ADPCM_SYSWORK.w		* 他のIOCSコール実行中?
		bne		@f
		tst.l		play_flag-mpw(a6)	* MPCM演奏中?
		bne		@f

		move.b		#$24,ADPCM_SYSWORK.w	* $65 実行中

		move.w		d0,sr

		bsr		ADPCM_mode		* ADPCMの周波数/PAN設定(d1.wで)

		lea.l		DMA3,a0			* DMA初期化(録音用)
		move.w		#$8082,DCR(a0)		* I/O -> メモリ転送
		move.b		#$04,SCR(a0)
		move.b		#$01,CPR(a0)
		move.b		#$05,MFC(a0)
		move.b		#$05,DFC(a0)
		move.l		(a1)+,MAR(a0)		* 録音メモリのアドレス
		move.l		#ADPCM+3,DAR(a0)	* ADPCM データレジスタ
		move.w		(a1)+,d0
		andi.w		#$ff00,d0		* $ff00以上は転送しないよ
		move.w		d0,MTC(a0)		* 転送長をDMAに設定
		move.b		CSR(a0),CSR(a0)		* CSR all clear
		move.b		#$88,DCCR(a0)		* 通常動作/割り込み有り
		move.b		#$04,ADPCM+1		* ADPCM recording start

		movea.l		(a1)+,a1
		move.l		a1,d0			* テーブル1個しかない？
		beq		1f

		move.l		(a1)+,BAR(a0)		* 次のアドレス
		move.w		(a1)+,d0
		andi.w		#$ff00,d0		* $ff00以上は転送しないよ
		move.w		d0,BTC(a0)		* 残り長さ
		move.b		#$05,BFC(a0)
		move.b		CSR(a0),CSR(a0)		* CSR all clear
		move.b		#$48,DCCR(a0)		* 継続動作/転送終了割込あり

		movea.l		(a1)+,a1

1:		move.l		a1,IOCS_REC_CTBL_ADR-mpw(a6)	* 次のテーブルアドレス
		bra		1f

@@:		move.w		d0,sr			* sr 戻す
1:		movem.l		(sp)+,d2/a0/a6
		rts

*===============================================================
* IOCS	_ADPCMSNS
*===============================================================

mpcm_iocs_66:	moveq.l		#0,d0			* _ADPCMSNS
		move.b		ADPCM_SYSWORK.w,d0
		rts

*===============================================================
* IOCS	_ADPCMMOD
* call		: d1.l = 制御番号
*===============================================================

mpcm_iocs_67:	movem.l		a0/a5-a6,-(sp)		* _ADPCMMOD
		lea.l		IOCS_work(pc),a5
		lea.l		mpw(pc),a6

		cmpi.b		#$02,d1
		bcc		@f

		clr.b		EFCT_PLAY_FLAG(a5)	* d1.l = $00/$01 終了/停止
		movem.l		(sp)+,a0/a5-a6
		rts

@@:		st.b		EFCT_PLAY_FLAG(a5)	* d1.l = $02 再開

		move.w		sr,d0
		ori.w		#$0700,sr		* 割り込み禁止

		tst.l		play_flag-mpw(a6)
		bne		@f
		bsr		func_00xx_DMA_start
@@:		move.w		d0,sr
		movem.l		(sp)+,a0/a5-a6
		rts

*===============================================================
* ADPCM_mode	: ADPCMのモードを切り替える
* call		: d1.w = サンプリング周波数*256+PAN
*		  a6.l = ワークアドレス
* return	: 無し
* breaks	: 無し
*===============================================================

ADPCM_mode:	movem.l		d0-d2,-(sp)

		moveq.l		#$03,d2
		and.b		d1,d2
		move.b		pan_tbl3-mpw(a6,d2.w),d2	* d2.b = ADPCM PAN
		lsr.w		#8,d1
		moveq.l		#$f0,d0
		and.b		$E9A005,d0
		or.b		ADPCM_clk_tbl0(pc,d1.w),d0	* 周波数設定値を得る
		or.b		d2,d0			* PANと合成
		move.b		d0,$E9A005		* 8255 ポートC 設定(PAN=3)

		moveq.l		#$7f,d0			* OPM レジスタ $1Bの設定
		and.b		$09da.w,d0
		or.b		ADPCM_clk_tbl1(pc,d1.w),d0
		move.b		d0,$09da.w
@@:		tst.b		$E90003
		bmi.s		@b
		move.b		#$1b,$E90001
		nop
		nop
		nop
		nop					* high clock 対応
		move.b		d0,$E90003

		movem.l		(sp)+,d0-d2
		rts
*				3.9  5.2  7.8 10.4 15.6 20.8 31.2 kHz
ADPCM_clk_tbl0:	.dc.b		$00, $04, $00, $04, $08, $0c, $0c	* to 8255
ADPCM_clk_tbl1:	.dc.b		$80, $80, $00, $00, $00, $80, $00	* to YM2151


*▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽
*
*		DMA割り込み処理部分
*
*△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△

*===============================================================
*		IOCS録音用割り込みルーチン
*===============================================================

mpcm_rec:	move.b		ADPCM_SYSWORK.w,d0
		cmp.b		#$14,d0
		beq		mpcm_rec_63
		cmp.b		#$24,d0
		beq		mpcm_rec_65

* 通常の録音
mpcm_rec_61:	move.l		IOCS_REC_LEN-mpw(a6),d2
		bpl		@f

*		残り長さがマイナス
		move.b		#$01,ADPCM+1		* ADPCM 動作停止

		lea.l		DMA3,a0
		move.b		#$04,SCR(a0)		* SCR clear
		move.b		#$10,DCCR(a0)		* CCR DMA停止割り込み無し
		move.b		#$80,DCR(a0)		* DCR clear
		move.b		#$02,OCR(a0)		* OCR clear
		move.b		#$01,CPR(a0)
		move.b		#$05,MFC(a0)
		move.b		#$05,DFC(a0)

		move.w		frq_offset-mpw(a6),d0
		beq		2f
		cmpi.w		#4*2,d0
		beq		1f
		move.w		#$0203,d1		* ADPCM 7.8kHz
		bra		@f
1:		move.w		#$0403,d1		* ADPCM 15.6kHz
		bra		@f
2:		move.w		#$0603,d1		* ADPCM 31.2kHz
@@:		bsr		ADPCM_mode		* 周波数15.6kHz/PAN左右
		move.b		#$02,ADPCM+1		* ADPCM再生動作開始
		clr.b		ADPCM_SYSWORK.w		* IOCS 動作終了
		bra		mpcm_end

@@:		bne		@f

*		残り長さが０
		st.b		IOCS_REC_LEN-mpw(a6)	* 次は無いよ
		bra		mpcm_end		

*		残り長さが０以上
@@:		cmpi.l		#$0000_ff00,d2
		bhi		1f			* d2.l > ff00なら
		clr.l		IOCS_REC_LEN-mpw(a6)	* 残り長さを０にしておく
		bra		2f
1:		sub.l		#$0000_ff00,d2
		move.l		d2,IOCS_REC_LEN-mpw(a6)	* 残りの長さを保存しておく
		move.w		#$ff00,d2
2:		move.w		d2,MTC(a0)		* 転送長をDMAに設定

		move.b		#$05,BFC(a0)
		move.b		CSR(a0),CSR(a0)		* CSR all clear
		move.b		#$48,DCCR(a0)		* 継続動作/転送終了割込あり

		bra		mpcm_end

*アレイ録音
mpcm_rec_63:	move.l		IOCS_REC_CTBL_N-mpw(a6),d2
		beq		@f

		move.l		(a1)+,BAR(a0)		* 次のアドレス
		move.w		(a1)+,d0
		andi.w		#$ff00,d0		* $ff00以上は転送しないよ
		move.w		d0,BTC(a0)		* 残り長さ
		move.b		#$05,BFC(a0)
		move.b		CSR(a0),CSR(a0)		* CSR all clear
		move.b		#$48,DCCR(a0)		* 継続動作/転送終了割込あり

		subq.l		#1,d2
		move.l		d2,IOCS_REC_CTBL_N-mpw(a6)
		bra		mpcm_end

@@:		move.b		#$01,ADPCM+1		* ADPCM 動作停止

		lea.l		DMA3,a0
		move.b		#$04,SCR(a0)		* SCR clear
		move.b		#$10,DCCR(a0)		* CCR DMA停止割り込み無し
		move.b		#$80,DCR(a0)		* DCR clear
		move.b		#$02,OCR(a0)		* OCR clear
		move.b		#$01,CPR(a0)
		move.b		#$05,MFC(a0)
		move.b		#$05,DFC(a0)

		move.w		frq_offset-mpw(a6),d0
		beq		2f
		cmpi.w		#4*2,d0
		beq		1f
		move.w		#$0203,d1		* ADPCM 7.8kHz
		bra		@f
1:		move.w		#$0403,d1		* ADPCM 15.6kHz
		bra		@f
2:		move.w		#$0603,d1		* ADPCM 31.2kHz
@@:		bsr		ADPCM_mode		* 周波数15.6kHz/PAN左右

		move.b		#$02,ADPCM+1		* ADPCM再生動作開始
		clr.b		ADPCM_SYSWORK.w		* IOCS 動作終了
		bra		mpcm_end

* リンクアレイ録音
mpcm_rec_65:	movea.l		IOCS_REC_CTBL_ADR-mpw(a6),a1
		move.l		a1,d0
		beq		@f

		move.l		(a1)+,BAR(a0)		* 次のアドレス
		move.w		(a1)+,d0
		andi.w		#$ff00,d0		* $ff00以上は転送しないよ
		move.w		d0,BTC(a0)		* 残り長さ
		move.b		#$05,BFC(a0)
		move.b		CSR(a0),CSR(a0)		* CSR all clear
		move.b		#$48,DCCR(a0)		* 継続動作/転送終了割込あり

		movea.l		(a1)+,a1
		move.l		a1,IOCS_REC_CTBL_ADR-mpw(a6)
		bra		mpcm_end

@@:		move.b		#$01,ADPCM+1		* ADPCM 動作停止

		lea.l		DMA3,a0
		move.b		#$04,SCR(a0)		* SCR clear
		move.b		#$10,DCCR(a0)		* CCR DMA停止割り込み無し
		move.b		#$80,DCR(a0)		* DCR clear
		move.b		#$02,OCR(a0)		* OCR clear
		move.b		#$01,CPR(a0)
		move.b		#$05,MFC(a0)
		move.b		#$05,DFC(a0)

		move.w		frq_offset-mpw(a6),d0
		beq		2f
		cmpi.w		#4*2,d0
		beq		1f
		move.w		#$0203,d1		* ADPCM 7.8kHz
		bra		@f
1:		move.w		#$0403,d1		* ADPCM 15.6kHz
		bra		@f
2:		move.w		#$0603,d1		* ADPCM 31.2kHz
@@:		bsr		ADPCM_mode		* 周波数15.6kHz/PAN左右

		move.b		#$02,ADPCM+1		* ADPCM再生動作開始
		clr.b		ADPCM_SYSWORK.w		* IOCS 動作終了
		bra		mpcm_end

*===============================================================
*		DMAエラー割り込み処理
*===============================================================

mpcm_err:
		move.b		DMA3+CER,DMA_err_stat
*		rte

*===============================================================
*		DMA転送終了割り込み処理
*===============================================================

mpcm:		ori.w		#$0700,sr		* 割り込み禁止
		addq.w		#1,mpcm_nest
		beq		@f

*		多重割り込み対応部分
		move.b		DMA3+CSR,DMA3+CSR	* CSR リセット
		bmi		1f			* 転送が終了していたら
		rte
1:
		btst.b		#2,ADPCM_SYSWORK.w	* 録音の時か？
		bne		2f
		move.b		#$88,ADPCM+3		* 終了
		rte
2:		move.b		#$01,ADPCM+1		* 録音動作停止
		clr.b		ADPCM_SYSWORK.w
		rte

@@:		tst.b		mpcm_debug
		beq		@f
		move.w		#%00000_00000_01111_0,TEXT_PALET

@@:		movem.l		d0-d7/a0-a6,-(sp)

		lea.l		mpw(pc),a6		* MPCM 割り込みワークの先頭

		ori.w		#$0700,sr		* 割り込み禁止
		move.l		MFP+$12,d0
		move.l		d0,-(sp)		* IMRA/IMRB 保存
		and.l		IMR_mask-mpw(a6),d0
		move.l		d0,MFP+$12		* IMRA/IMRB 書き替え

		move.w		sr,d0			* mpu maskの変更
		andi.w		#$f8ff,d0
		or.w		MPU_mask-mpw(a6),d0
		move.w		d0,sr

		btst.b		#2,ADPCM_SYSWORK.w	* 録音?
		bne		mpcm_rec		* (オフセットの関係で)上にあります


*		PANの設定
		tst.b		pan_set_flag-mpw(a6)
		beq		@f
		clr.b		pan_set_flag-mpw(a6)	* フラグクリア
		moveq.l		#$fc,d0
		and.b		$E9A005,d0		* 8255 PORT C
		or.b		ADPCM_pan-mpw(a6),d0
		move.b		d0,$E9A005		* ADPCM PAN 変更


*		16bit PCM 合成バッファ初期化
mpcm_loop:
@@:		lea.l		PCM_out+MIX_SIZE*4-mpw(a6),a1
		moveq.l		#0,d0
		moveq.l		#0,d1
		moveq.l		#0,d2
		moveq.l		#0,d3
		moveq.l		#0,d4
		moveq.l		#0,d5
		moveq.l		#0,d6
		moveq.l		#0,d7
		movem.l		d0-d7,-(a1)
		movem.l		d0-d7,-(a1)
		movem.l		d0-d7,-(a1)
		movem.l		d0-d7,-(a1)
		movem.l		d0-d7,-(a1)
		movem.l		d0-d7,-(a1)



*		演奏チャンネルPCM合成
		clr.l		play_flag-mpw(a6)	* play_flag クリア
		lea.l		ch0_work(pc),a5		* チャンネルワーク

		REPT		CH_MAX
		tst.b		CH_PLAY_FLAG(a5)
		beq		@f
		lea.l		PCM_out-mpw(a6),a1	* PCM 作成バッファ
		move.l		a6,-(sp)		* a6.l保存
		movea.l		CH_JMP_ADR(a5),a0
		jsr		(a0)
		movea.l		(sp)+,a6
		move.l		CH_CHANNEL_MASK(a5),d0
		or.l		d0,play_flag-mpw(a6)
@@:		lea.l		CH_WORK_SIZE(a5),a5
		ENDM

*		効果音チャンネルPCM合成
		REPT		EFCT_MAX
		tst.b		EFCT_PLAY_FLAG(a5)
		beq		@f
		lea.l		PCM_out-mpw(a6),a1	* PCM 作成バッファ
		movea.l		EFCT_JMP_ADR(a5),a0
		jsr		(a0)
		move.l		EFCT_CH_MASK(a5),d0
		or.l		d0,play_flag-mpw(a6)
@@:		lea.l		EFCT_WORK_SIZE(a5),a5
		ENDM

*		IOCSチャンネルPCM合成
		tst.b		EFCT_PLAY_FLAG(a5)	* IOCS再生中？
		beq		@f
		lea.l		PCM_out-mpw(a6),a1	* PCM 作成バッファ
		movea.l		EFCT_JMP_ADR(a5),a0
		jsr		(a0)
		move.l		EFCT_CH_MASK(a5),d0
		or.l		d0,play_flag-mpw(a6)

@@:		tst.l		play_flag-mpw(a6)	* 演奏終了か?
		bne		@f

mpcm_overload:	lea.l		DMA3,a0			* 演奏終了処理
		ori.w		#$0700,sr
		btst.b		#3,CSR(a0)		* CSR ACTビット(過負荷時のチェック)
		bne		1f

		move.w		#8,MTC(a0)		* DMAが止まっている時
		move.b		#$05,MFC(a0)
		move.l		#dummy_ADPCM,MAR(a0)	* $88を通常出力
		move.b		CSR(a0),CSR(a0)		* CSR all clear
		move.b		#$80,DCCR(a0)		* DMA START/割り込み無し
		bra		mpcm_end

1:
		move.w		#8,BTC(a0)
		move.b		#$05,BFC(a0)
		move.l		#dummy_ADPCM,BAR(a0)	* $88を継続で出力
		move.b		CSR(a0),CSR(a0)
		move.b		#$40,DCCR(a0)		* 継続動作/転送終了割込無し
		bra		mpcm_end

@@:

*--------------	PCM -> ADPCM 変換 ----------------

		tst.b		mpcm_debug-mpw(a6)
		beq		@f
		move.w		#%00000_00000_11111_0,TEXT_PALET

@@:		neg.w		ADPCM_out_flag-mpw(a6)
		bmi		1f
		lea.l		ADPCM_out0-mpw(a6),a0
		bra		@f
1:		lea.l		ADPCM_out1-mpw(a6),a0	* a0.l = 今回作成するADPCMバッファ

@@:		lea.l		PCM_out-mpw(a6),a1	* a1.l = 16bit PCM 合成バッファ
		movea.l		PtoA_X-mpw(a6),a2	* a2.l = PCM -> ADPCM テーブルアドレス
		move.w		PtoA_Y-mpw(a6),d1	* d1.w = PCM -> ADPCM 予測値
		moveq.l		#0,d2			* d2.w = 上位8bit CLR
		moveq.l		#$08,d5
		movea.w		d5,a3			* a3.w = $0008
		moveq.l		#$0f,d5			* d5.w = $000f
		moveq.l		#$80,d6
		movea.w		d6,a4			* a4.w = $0080
		moveq.l		#$f0,d6			* d6.w = $00f0


		REPT		MIX_SIZE		* MIX_SIZE*2個の16PCMを処理

		move.w		(a1)+,d0
		sub.w		d1,d0
		bmi		2f
		cmp.w		(a2)+,d0
		bcc		1f
		move.b		48(a2,d0.w),d2
		add.w		d2,a2
1:		move.w		(a2)+,d3
		and.w		d5,d3			* andi.w #$000f,d3
		add.w		(a2)+,d1
		bra.s		3f

2:		neg.w		d0
		cmp.w		(a2)+,d0
		bcc		1f
		move.b		48(a2,d0.w),d2
		add.w		d2,a2
1:		move.w		(a2)+,d3
		and.w		d5,d3			* andi.w #$000f,d3
		add.w		a3,d3			* ori.w  #$0008,d3
		sub.w		(a2)+,d1

3:		adda.w		(a2),a2


		move.w		(a1)+,d0
		sub.w		d1,d0
		bmi		2f
		cmp.w		(a2)+,d0
		bcc		1f
		move.b		48(a2,d0.w),d2
		add.w		d2,a2
1:		move.w		(a2)+,d4
		and.w		d6,d4			* andi.w #$00f0,d4
		or.w		d4,d3
		add.w		(a2)+,d1
		bra.s		3f

2:		neg.w		d0
		cmp.w		(a2)+,d0
		bcc		1f
		move.b		48(a2,d0.w),d2
		add.w		d2,a2
1:		move.w		(a2)+,d4
		and.w		d6,d4			* andi.w #$00f0,d4
		add.w		a4,d4			* ori.w  #$0080,d4
		or.w		d4,d3
		sub.w		(a2)+,d1

3:		adda.w		(a2),a2
		move.b		d3,(a0)+

		ENDM

		move.l		a2,PtoA_X-mpw(a6)	* 次の変換に備えて保存
		move.w		d1,PtoA_Y-mpw(a6)

*--------------	PCM -> ADPCM 変換終了 ----------------


*		DMA 継続動作準備

		lea.l		-48(a0),a4

		lea.l		DMA3,a0
		move.w		sr,d0
		ori.w		#$0700,sr
		btst.b		#3,CSR(a0)		* CSR ACTビット(過負荷時のチェック)
		bne		@f

		addi.w		#1,overload_ctr-mpw(a6)
		bne		1f
		trap		#9
		lea.l		ch0_work(pc),a5
		REPT		CH_MAX
		clr.b		CH_PLAY_FLAG(a5)	* 演奏チャンネル演奏停止
		clr.b		CH_KEY_STAT(a5)		* KEY OFF
		lea.l		CH_WORK_SIZE(a5),a5
		ENDM
		REPT		EFCT_MAX
		clr.b		EFCT_PLAY_FLAG(a5)	* 効果音チャンネル演奏停止
		lea.l		EFCT_WORK_SIZE(a5),a5
		ENDM
		clr.b		EFCT_PLAY_FLAG(a5)	* IOCSの演奏停止

		clr.l		play_flag-mpw(a6)	* 演奏フラグの取消
		clr.b		ADPCM_SYSWORK.w		* ADPCMのIOCS 停止
		bra		mpcm_overload		* ADPCM停止処理へ

1:		moveq.l		#MIX_SIZE,d1
		moveq.l		#5,d2

		move.w		d1,MTC(a0)		* $88+$80を1回分転送
		move.b		d2,MFC(a0)
		move.l		#dummy_ADPCM,MAR(a0)

		move.w		d1,BTC(a0)		* $88+$80をもう1回分転送
		move.b		d2,BFC(a0)
		move.l		a4,BAR(a0)		* 今回処理したADPCMを通常で出力

		move.b		CSR(a0),CSR(a0)		* CSR all clear
		move.b		#$c8,DCCR(a0)		* 動作開始/継続モード/転送終了割込あり

		move.w		d0,sr
	.ifdef	DEBUG
		movea.l		ofwrite-mpw(a6),a0
		move.b		#$ff,(a0)+		* オーバーフローを知らせる
		move.l		a0,ofwrite-mpw(a6)
	.endif
		tst.b		mpcm_debug-mpw(a6)
		beq		mpcm_loop
		move.w		#%01111_01111_01111_0,TEXT_PALET * 過負荷時は白
		bra		mpcm_loop		* もう一回頑張れ


@@:		move.w		#MIX_SIZE,BTC(a0)	* 通常処理
		move.b		#$05,BFC(a0)
		move.l		a4,BAR(a0)
		move.b		CSR(a0),CSR(a0)		* CSR all clear
		move.b		#$48,DCCR(a0)		* 継続動作/転送終了割込あり

mpcm_end:	tst.b		mpcm_debug-mpw(a6)
		beq		1f
		move.w		#%00000_00000_00000_0,TEXT_PALET	* 終了
1:		move.w		#-1,mpcm_nest
		move.w		#-100,overload_ctr
		move.l		(sp)+,MFP+$12		* IMRA/IMRB 復帰

		movem.l		(sp)+,d0-d7/a0-a6
		rte


*===============================================================
*		ＡＤＰＣＭ処理ルーチン
*===============================================================

		.include	adp_high.s
		.include	adp_low.s
		.include	adp_0101.s
		.include	adp_0203.s
		.include	adp_0102.s
		.include	adp_0103.s
		.include	adp_0104.s

AtoP_LOOP:	move.l		a2,CH_LOOP_X(a5)	* ループ先頭でのX
		move.w		d1,CH_LOOP_Y(a5)	* ループ先頭での基本PCM
		movea.l		CH_LPEND_ADR(a5),a3
		lea.l		AtoP_LPEND(pc),a4
		move.l		a3,CH_TRAP_ADR(a5)
		move.l		a4,CH_TRAP_ROUTINE(a5)	* 次のトラップは、ループ終了位置
		rts

AtoP_LPEND:	tst.l		CH_LPTIME(a5)		* 無限ループか?
		beq		1f
		sub.l		#1,CH_LPTIME_CTR(a5)
		beq		2f
1:		movea.l		CH_LOOP_X(a5),a2
		move.w		CH_LOOP_Y(a5),d1
		movea.l		CH_LPSTART_ADR(a5),a0	* ループポイントに戻る
		rts
2:		movea.l		CH_END_ADR(a5),a3	* a3.l = ADPCMデータ終了アドレス
		cmpa.l		a3,a0
		bcc		AtoP_END		* LPEND (>)= DATA ENDの場合に対処
		lea.l		AtoP_END(pc),a4		* a4.l = データ終了処理アドレス
		move.l		a3,CH_TRAP_ADR(a5)
		move.l		a4,CH_TRAP_ROUTINE(a5)	* 次のトラップは、データ終了位置
		rts

AtoP_END:	addq.l		#4,sp			* 戻りアドレス破棄
		clr.b		CH_PLAY_FLAG(a5)	* 演奏停止
		clr.b		CH_KEY_STAT(a5)		* KEY OFF状態
		rts


*===============================================================
*		１６ｂｉｔＰＣＭ処理ルーチン
*===============================================================

		.include	p16_high.s
		.include	p16_low.s
		.include	p16_0101.s
		.include	p16_0203.s
		.include	p16_0102.s
		.include	p16_0103.s
		.include	p16_0104.s


PCM16_LPEND:	tst.l		CH_LPTIME(a5)
		beq		1f			* 無限ループだった場合
3:		sub.l		#1,CH_LPTIME_CTR(a5)
		beq		2f
1:		suba.l		a3,a0			* 現在アドレス-終点アドレスでアドレス差分計算
		adda.l		CH_LPSTART_ADR(a5),a0	* それをループ始点に足し、現在アドレスとする
		cmpa.l		a3,a0
		bcc		3b			* まだループ終点より大きい
		rts
2:		movea.l		CH_END_ADR(a5),a3	* 次のトラップはデータ終了
		cmpa.l		a3,a0
		bcc		PCM16_END		* LPEND (>)= DATA END に対応
		lea.l		PCM16_END(pc),a4
		move.l		a3,CH_TRAP_ADR(a5)
		move.l		a4,CH_TRAP_ROUTINE(a5)
		rts

PCM16_END:	addq.l		#4,sp			* 戻りアドレス破棄
		clr.b		CH_PLAY_FLAG(a5)	* 演奏停止
		clr.b		CH_KEY_STAT(a5)		* KEY OFF状態
		rts


*===============================================================
*		８ｂｉｔＰＣＭ処理ルーチン
*===============================================================

		.include	p8_high.s
		.include	p8_low.s
		.include	p8_0101.s
		.include	p8_0203.s
		.include	p8_0102.s
		.include	p8_0103.s
		.include	p8_0104.s

PCM8_LPEND:	tst.l		CH_LPTIME(a5)
		beq		1f			* 無限ループだった場合
3:		sub.l		#1,CH_LPTIME_CTR(a5)
		beq		2f
1:		suba.l		a3,a0			* 現在アドレス-終点アドレスでアドレス差分計算
		adda.l		CH_LPSTART_ADR(a5),a0	* それをループ始点に足し、現在アドレスとする
		cmpa.l		a3,a0
		bcc		3b			* まだループ終点より大きい
		rts
2:		movea.l		CH_END_ADR(a5),a3	* 次のトラップはデータ終了
		cmpa.l		a3,a0
		bcc		PCM8_END		* LPEND (>)= DATA END に対応
		lea.l		PCM8_END(pc),a4
		move.l		a3,CH_TRAP_ADR(a5)
		move.l		a4,CH_TRAP_ROUTINE(a5)
		rts

PCM8_END:	addq.l		#4,sp			* 戻りアドレス破棄
		clr.b		CH_PLAY_FLAG(a5)	* 演奏停止
		clr.b		CH_KEY_STAT(a5)		* KEY OFF状態
		rts

*===============================================================
*		登録データが無い場合の処理ルーチン
*===============================================================

NO_PCM:		clr.b		CH_PLAY_FLAG(a5)	* 演奏停止
		clr.b		CH_KEY_STAT(a5)		* KEY OFF状態
		rts

*===============================================================
*		各ＰＣＭキーオフ消音処理ルーチン
*===============================================================

make_keyoff_PCM:
		move.w		CH_LAST_VPCM(a5),d0	* 最後の音量変換付PCM
		move.w		d0,d1
		asr.w		#4,d1			* d1.w=d0.w/16
		moveq.l		#4-1,d2
@@:		add.w		d0,(a1)+		* 音量を下げていって消音
		sub.w		d1,d0
		add.w		d0,(a1)+
		sub.w		d1,d0
		add.w		d0,(a1)+
		sub.w		d1,d0
		add.w		d0,(a1)+
		sub.w		d1,d0
		dbra		d2,@b

		clr.w		CH_LAST_VPCM(a5)	* 音量変換付PCM=0
		rts

*===============================================================
*		IOCS専用ADPCM処理ルーチン
*===============================================================

		.include	adp_effect.s
		.include	p16_effect.s
		.include	p8_effect.s


*===============================================================
*		デバッグ専用ルーチン
*===============================================================
.ifdef	DEBUG

print_str:	movem.l		a0-a3,-(sp)
		lea.l		$f3a000,a0		* character ROM addr
		movea.l		text_adr(pc),a3

prtstr_loop:	moveq.l		#0,d0
		move.b		(a1)+,d0
		beq		prtstr_end
		cmp.b		#CR,d0
		beq		prtstr_CR
		cmp.b		#LF,d0
		beq		prtstr_LF
		lsl.w		#3,d0		* 8倍
		lea.l		(a0,d0.w),a2
		move.b		(a2)+,(a3)+
		move.b		(a2)+,128*1-1(a3)
		move.b		(a2)+,128*2-1(a3)
		move.b		(a2)+,128*3-1(a3)
		move.b		(a2)+,128*4-1(a3)
		move.b		(a2)+,128*5-1(a3)
		move.b		(a2)+,128*6-1(a3)
		move.b		(a2)+,128*7-1(a3)
		bra		prtstr_loop

prtstr_CR:	move.l		a3,d0
		andi.l		#$00ffff80,d0
		movea.l		d0,a3
		bra		prtstr_loop

prtstr_LF:	lea.l		128*8(a3),a3
		bra		prtstr_loop

prtstr_end:	move.l		a3,text_adr
		movem.l		(sp)+,a0-a3
		rts

print_char:	movem.l		a0-a3,-(sp)
		lea.l		$f3a000,a0
		movea.l		text_adr(pc),a3

		moveq.l		#0,d0
		move.b		d1,d0
		beq		prtchr_end
		cmp.b		#CR,d0
		beq		prtchr_CR
		cmp.b		#LF,d0
		beq		prtchr_LF
		lsl.w		#3,d0		* 8倍
		lea.l		(a0,d0.w),a2
		move.b		(a2)+,(a3)+
		move.b		(a2)+,128*1-1(a3)
		move.b		(a2)+,128*2-1(a3)
		move.b		(a2)+,128*3-1(a3)
		move.b		(a2)+,128*4-1(a3)
		move.b		(a2)+,128*5-1(a3)
		move.b		(a2)+,128*6-1(a3)
		move.b		(a2)+,128*7-1(a3)

prtchr_end:	move.l		a3,text_adr
		movem.l		(sp)+,a0-a3
		rts

prtchr_CR:	move.l		a3,d0
		andi.l		#$00ffff80,d0
		movea.l		d0,a3
		bra		prtchr_end

prtchr_LF:	lea.l		128*8(a3),a3
		bra		prtchr_end

text_adr:	.dc.l		TEXT_RAM			* text ram addr counter

VALtoSTRl:	move.l		#'0000',d1
		lea.l		STRbuffl(pc),a0
		move.l		d1,(a0)+
		move.l		d1,(a0)+
@@:		move.l		d0,d1
		andi.w		#$0f,d1
		move.b		ConvTbl(pc,d1.w),-(a0)
		lsr.l		#4,d0
		bne		@b
		rts

STRbuffl:	.dc.b		'00000000',0
		.even

VALtoSTRw:	move.l		#'0000',d1
		lea.l		STRbuffw+4(pc),a0
		move.l		d1,(a0)+
		andi.l		#$0000ffff,d0
@@:		move.l		d0,d1
		andi.w		#$0f,d1
		move.b		ConvTbl(pc,d1.w),-(a0)
		lsr.l		#4,d0
		bne		@b
		rts

STRbuffw:	.dc.b		'    0000',0
		.even

VALtoSTRb:	move.w		#'00',d1
		lea.l		STRbuffb+6(pc),a0
		move.w		d1,(a0)+
		andi.l		#$000000ff,d0
@@:		move.l		d0,d1
		andi.w		#$0f,d1
		move.b		ConvTbl(pc,d1.w),-(a0)
		lsr.l		#4,d0
		bne		@b
		rts

STRbuffb:	.dc.b		'      00',0
		.even

ConvTbl:	.dc.b		'0123456789ABCDEF'
		.even

.endif

*▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽
*
*		でっかいテーブル
*
*△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△

AtoP_tbl:	.ds.b		49*256*6		* ADPCM -> PCM 変換テーブル
PtoA_tbl:	.ds.b		32014			* PCM -> ADPCM 作成テーブル



*▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽
*
*		非常駐部分
*
*△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△△

		.text

mpcm_start:	pea.l		title_mes(pc)
		DOS		_PRINT
		addq.l		#4,sp
		movea.l		a0,a6			* a0/a6=メモリ管理ポインタ
		bsr		option_check

*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!Thanks to E.Tachibana
               clr.l           -(sp)
               DOS             _SUPER
               move.l          d0,(sp)
 
               move.l          a6,d0
 @@:           movea.l         d0,a6
               move.l          (a6),d0                 * 先頭のブロックまで遡る
               bne             @b
keep_check_loop:
               cmpi.b          #$ff,(4,a6)
               bne             keep_check_next         * 常駐プロセスではない
               lea             ($100,a6),a5
               move.l          (8,a6),d1
               sub.l           a5,d1
               subq.l          #8,d1
               bcs             keep_check_next         * ブロックのサイズが小さすぎる
                move.l          (a5),d1
               cmp.l           (header),d1
               bne             keep_check_next         * ヘッダが一致しない
               move.l          (4,a5),d1
               cmp.l           (header+4),d1
               bne             keep_check_next         * ヘッダが一致しない
 
               DOS             _SUPER
               addq.l          #4,sp
                bra             keeped                  * 常駐していた
keep_check_next:
               move.l          (12,a6),d0              * 次のブロック
               movea.l         d0,a6
               bne             keep_check_loop
 
               DOS             _SUPER
               addq.l          #4,sp
               bra             not_keeped              * 常駐してない
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!Thanks to E.Tachibana

*keep_check:	movea.l		(a6),a6
*		cmpa.l		#$10000,a6
*		bcs		not_keeped		* 常駐してない
*		lea.l		$100(a6),a5
*		move.l		(a5),d1
*		cmp.l		header,d1
*		bne		keep_check		* ヘッダが一致しない
*		move.l		4(a5),d1
*		cmp.l		header+4,d1
*		bne		keep_check		* ヘッダが一致しない
*		bra		keeped			* 常駐していた


*		<< 常駐していなかった場合 >>

not_keeped:	btst.b		#0,option_flag(pc)	* -r check
		bne		error0			* 常駐してないのに常駐解除は出来ない

		btst.b		#1,option_flag(pc)	* -d check
		beq		@f
		tst.b		D_option_work
		bmi		1f
		move.b		D_option_work(pc),mpcm_debug
		bra		@f
1:		st.b		mpcm_debug		* degug フラグ状態反転

@@:		move.w		F_option_work(pc),frq_offset

@@:		btst.b		#4,option_flag(pc)	* -v check
		beq		@f
		move.l		a6,-(sp)
		moveq.l		#1,d1
		lea.l		mpw,a6
		jsr		func_8005
		move.l		(sp)+,a6
		st.b		volume_mode		* -v flag set

@@:		bsr		make_AtoP_tbl		* ADPCM -> PCM 変換テーブル作成
		bsr		make_PtoA_tbl		* PCM -> ADPCM 変換テーブル作成
		bsr		init_mpcm		* 割り込みワーク/ADPCM/DMA初期化
		bsr		init_iocs		* iocsコールの処理横取り初期化

		pea.l		keep_mes(pc)
		DOS		_PRINT
		addq.l		#4,sp

.ifdef	DEBUG
		bsr		MPCM_DEBUG
.endif

		clr.w		-(sp)
		lea.l		mpcm_start(pc),a0	* コンパイル時の為
		lea.l		header,a1
		suba.l		a1,a0
		move.l		a0,-(sp)
		DOS		_KEEPPR			* 常駐して終了

*		<< 既に常駐していた場合 >>

keeped:		tst.b		option_flag
		beq		error1

		btst.b		#0,option_flag(pc)	* r オプションが指定されている？
		beq		@f			* されてない

		tst.b		mpcm_locked-header(a5)	* 常駐解除処理
		bne		error2			* 占有されている

		move.w		#$01ff,d0
		trap		#1			* MPCM 全チャンネルキーオフ

		clr.l		-(sp)
		DOS		_SUPER
		move.l		d0,(sp)

*		lea.l		mpcm-header(a5),a0
*		cmp.l		$0130.w,a0
*		bne		errorC			* ベクタが書き換えられている

		move.b		#$01,$E92001		* ADPCM 停止

		move.w		sr,d0			* sr 保存
		ori.w		#$0700,sr		* 割り込み禁止

		move.l		trap1_vec_buff-header(a5),$0084.w	* trap 1 ベクタ戻す
		move.l		DMA_vec_buff-header(a5),$01a8.w		* DMA転送終了割り込み
		move.l		DMAERR_vec_buff-header(a5),$01ac.w	* DMA転送エラー割り込み

		move.w		d0,sr			* 割り込み許可

		bsr		recover_iocs		* IOCSコールを元に戻す

		DOS		_SUPER
		addq.l		#4,sp

		pea.l		$10(a6)
		DOS		_MFREE
		pea.l		free_mes(pc)
		DOS		_PRINT
		addq.l		#8,sp
		bra		keeped_end		* 常駐解除終了

@@:		btst.b		#1,option_flag(pc)	* -dオプションあり？
		beq		@f
		tst.b		D_option_work
		bmi		1f
		move.b		D_option_work(pc),mpcm_debug-header(a5)
		bra		2f
1:		tas.b		mpcm_debug-header(a5)	* degug フラグ状態反転
		beq		2f
		clr.b		mpcm_debug-header(a5)
2:		pea.l		change_debugmode_mes(pc)
		DOS		_PRINT
		addq.l		#4,sp

@@:		btst.b		#3,option_flag(pc)	* -s option
		beq		@f

		pea.l		debug_mode_mes(pc)	* デバッグモード状態表示
		DOS		_PRINT
		tst.b		mpcm_debug-header(a5)
		beq		1f
		pea.l		on_mes(pc)
		DOS		_PRINT
		bra		2f
1:		pea.l		off_mes(pc)
		DOS		_PRINT
2:		addq.l		#8,sp

		pea.l		adpcm_mode_mes(pc)	* adpcm動作周波数表示
		DOS		_PRINT
		move.w		frq_offset-header(a5),d0
		beq		2f
		cmpi.w		#4*2,d0
		beq		1f
		pea.l		adpcm7k_mes(pc)
		bra		3f
1:		pea.l		adpcm15k_mes(pc)
		bra		3f
2:		pea.l		adpcm31k_mes(pc)
3:		DOS		_PRINT
		addq.l		#8,sp

		pea.l		pitch_mode_mes(pc)
		DOS		_PRINT
		tst.b		pitch_mode-header(a5)
		beq		1f
		pea.l		p_lock_mes(pc)
		DOS		_PRINT
		bra		2f
1:		pea.l		p_unlock_mes(pc)
		DOS		_PRINT
2:		addq.l		#8,sp

		pea.l		volume_mode_mes(pc)
		DOS		_PRINT
		tst.b		volume_mode-header(a5)
		beq		1f
		pea.l		v16_mes(pc)
		DOS		_PRINT
		bra		2f
1:		pea.l		v128_mes(pc)
		DOS		_PRINT
2:		addq.l		#8,sp

		tst.b		mpcm_locked-header(a5)
		beq		no_lock_entry		* 占有されてないよ
		pea.l		lock_entry_mes(pc)
		DOS		_PRINT
		addq.l		#4,sp

		lea.l		mplock_app_name-header(a5),a0
		moveq.l		#32-1,d1
1:		tst.b		(a0)
		beq		2f
		pea.l		(a0)
		DOS		_PRINT
		pea.l		crlf_mes(pc)
		DOS		_PRINT
		addq.l		#8,sp
2:		lea.l		32(a0),a0
		dbra		d1,1b

@@:
keeped_end:	DOS		_EXIT


.ifdef DEBUG
*
*		ＭＰＣＭのデバッグ用（本来不要）
*

MPCM_DEBUG:
		bsr		read_adpcm
break0:
		move.w		#$0200,d0
		lea.l		PCMHEADER(pc),a1
		trap		#1
		move.w		#$0300,d0	* 周波数
		moveq.l		#4,d1
		trap		#1
		move.w		#$0400,d0	* 音程
		move.w		#(64*64)+0,d1
		trap		#1
		move.w		#$0500,d0	* 音量
		moveq.l		#64,d1
		trap		#1
		move.w		#$0700,d0
		move.b		#$02,d1
		trap		#1
breakx:
		move.w		#$0000,d0	* KEY ON
		trap		#1

break1:
		move.w		#$0100,d0	* KEY OFF
		trap		#1

		rts


read_adpcm:	clr.w		-(sp)			*サンプルPCMの読み込み
		pea.l		PCMNAME(pc)
		DOS		_OPEN
		addq.l		#6,sp
		move.l		#-1,-(sp)
		pea.l		ADPCMBUFF
		move.w		d0,-(sp)
		DOS		_READ
		move.l		d0,PCMLEN
*		add.l		d0,d0
*		add.l		d0,d0
*		move.l		d0,PCMLEN
		move.w		(sp)+,d0
		addq.l		#8,sp
		move.w		d0,-(sp)
		DOS		_CLOSE
		addq.l		#2,sp
		rts


PCMHEADER:	.dc.l		$ff400000
		.dc.l		ADPCMBUFF
PCMLEN:		.dc.l		0
LPSTOFS:	.dc.l		$00000100
LPEDOFS:	.dc.l		$00000110
LPCNT:		.dc.l		$00001000

PCMNAME:	.dc.b		'C:\wacho\xpcm\V3\nob\TEST1.P8',0
		.even


.endif

*=======================================================
* option_check	: オプション判定&フラグとワークのセット
* call		: (a2)～=コマンドライン
* return	: (option_flag)とそれぞれのワークに値をセット
* breaks	: d0,d1,a2
*=======================================================
option_check:	clr.b		option_flag		* flag clear
		move.w		#4*2,F_option_work	* 周波数バッファ
		addq.l		#1,a2

opt_chk0:	move.b		(a2)+,d0
		tst.b		d0
		beq		opt_ret
		cmpi.b		#'/',d0			* option ?
		beq		opt_chk1
		cmpi.b		#'-',d0			* option ?
		beq		opt_chk1
		cmpi.b		#TAB,d0			* TAB	?
		beq		opt_chk0
		cmpi.b		#' ',d0			* SPACE ?
		beq		opt_chk0
		bra		usage			* 使用法表示

opt_chk1:	move.b		(a2)+,d0
		andi.b		#$df,d0			* 大文字に揃える

		cmpi.b		#'R',d0			* r = 常駐解除
		bne		opt_chk2
		bset.b		#0,option_flag		* bit0 = r 用フラグ
		bra		opt_chk0

opt_chk2:	cmpi.b		#'D',d0			* d = デバッグモード
		bne		opt_chk3
		bset.b		#1,option_flag		* bit1 = d 用フラグ
		move.b		(a2),d0
		cmpi.b		#'0',d0			* Not Debug mode !
		beq		1f
		cmpi.b		#'1',d0			* Debug mode !
		bne		2f
1:		addq.l		#1,a2
		subi.b		#'0',d0
		move.b		d0,D_option_work	* Write work : 0 / 1 
		bra		opt_chk0
2:		st.b		D_option_work		* write work : -1 (reverse)
		bra		opt_chk0

opt_chk3:	cmpi.b		#'F',d0			* h = ADPCM 動作周波数
		bne		opt_chk4
		move.b		(a2),d0
		andi.b		#$df,d0			* 大文字に揃える
		cmpi.b		#'H',d0			* High frq!
		bne		1f
		addq.l		#1,a2
		clr.w		F_option_work
		bra		opt_chk0
1:		cmpi.b		#'L',d0			* Low frq!
		bne		usage
		addq.l		#1,a2
		move.w		#4*4,F_option_work
		bra		opt_chk0


opt_chk4:	cmpi.b		#'S',d0			* s = mpcm状態表示
		bne		opt_chk5
		bset.b		#3,option_flag		* bit3 = s 用フラグ
		bra		opt_chk0

opt_chk5:	cmpi.b		#'V',d0			* v = 音量16段階固定
		bne		opt_chk6
		bset.b		#4,option_flag		* bit4 = s 用フラグ
		bra		opt_chk0

opt_chk6:	bra		usage			* 使用法表示

opt_ret:	rts

*===============================================================
* error		: 非常駐部分エラー処理
* usage		: 使い方表示
*===============================================================
error0:		pea.l		error0_mes(pc)
		bra		error
error1:		pea.l		error1_mes(pc)
		bra		error
error2:		pea.l		error2_mes(pc)
		bra		error
error3:		pea.l		error3_mes(pc)
		bra		error
usage:		pea.l		usage_mes(pc)
		bra		error

no_lock_entry:	pea.l		no_lock_entry_mes(pc)
		bra		error

error:		DOS		_PRINT
		addq.l		#4,sp
		moveq.l		#-1,d0
		DOS		_EXIT2

*===============================================================
* make_AtoP_tbl	: ADPCM -> PCM 変換テーブル作成
*===============================================================

make_AtoP_tbl:	lea.l		AtoP_tbl,a0		* テーブル作成領域アドレス
		lea.l		conv_tbl0(pc),a1	* ADPCM<->PCM変換作業表0
		lea.l		conv_tbl1(pc),a2	* ADPCM<->PCM変換作業表1
		lea.l		conv_tbl2(pc),a3	* ADPCM<->PCM変換作業表2

		moveq.l		#0,d1			* d1.b=X(0～48)のカウンタ
1:		moveq.l		#0,d0			* d0.b=ADPCM(0～255)のカウンタ

2:		move.w		d0,d2
		andi.w		#$000f,d2
		add.w		d2,d2			* d2.w=(A mod 16)*2
		move.w		(a1,d2.w),d3		* d3.w=C
		move.l		d1,d4			* d4.lの上位ワードは常に$0000
		add.w		d4,d4
		muls.w		(a2,d4.w),d3		* X から D を求める
		bpl		@f
		addq.w		#7,d3			* 切り捨て考慮
@@:		asr.w		#3,d3			* d3.w = (C*D)/8=dy1
		move.w		d1,d4
		add.w		(a3,d2.w),d4		* d4.w = X1 = X0+E
		bpl		@f
		moveq.l		#0,d4
@@:		cmp.w		#48+1,d4
		bcs		@f
		moveq.l		#48,d4

@@:		move.w		d0,d2
		andi.w		#$00f0,d2
		lsr.w		#3,d2			* d2=(A\16)*2
		move.w		(a1,d2.w),d6		* d6=C
		move.w		d4,d5
		add.w		d5,d5
		muls.w		(a2,d5.w),d6
		bpl		@f
		addq.w		#7,d6			* 切り捨て考慮
@@:		asr.w		#3,d6			* d6.w = (C*D)/8=dy2
		add.w		(a3,d2.w),d4		* d4.w = X2 = X0+E
		bpl		@f
		moveq.l		#0,d4
@@:		cmp.w		#48+1,d4
		bcs		@f
		moveq.l		#48,d4

@@:		move.w		d3,(a0)+		* dy1
		move.w		d6,256*2-2(a0)		* dy2それぞれをテーブルに格納
		lsl.w		#8,d4
		add.w		d4,d4
		move.w		d4,d6
		add.w		d4,d4
		add.l		d6,d4			* X2*256*2*3倍
		add.l		#AtoP_tbl+2,d4
		sub.l		a0,d4
		move.w		d4,256*2*2-2(a0)	* X2テーブルへのアドレス差分

		add.b		#1,d0
		bne		2b

		adda.w		#256*2*2,a0
		add.w		#1,d1
		cmp.w		#48+1,d1
		bcs		1b
		rts

*===============================================================
* make_PtoA_tbl	: PCM -> ADPCM 変換テーブル作成
*===============================================================

make_PtoA_tbl:	lea.l		PtoA_tbl,a0		* テーブル作成領域
		lea.l		conv_tbl0(pc),a1	* Oh!X 表2
		lea.l		conv_tbl1(pc),a2	* Oh!X 表3
		lea.l		conv_tbl2(pc),a3	* Oh!X 表4


		lea.l		conv_tbl3(pc),a4	* Xの先頭アドレステーブル作成
		movea.l		a4,a5
		moveq.l		#0,d7
1:		move.w		d7,d0
		add.w		d0,d0
		move.w		(a2,d0.w),d0
		muls.w		#7,d0
		lsr.w		#2,d0			* d0.w = d0.w*7/4
		add.w		#2+8*6,d0
		add.l		(a5)+,d0
		btst.l		#0,d0
		beq		@f
		addq.l		#1,d0			* テーブルは偶数からだから
@@:		move.l		d0,(a5)
		addq.w		#1,d7
		cmpi.w		#48,d7
		bcs		1b


		moveq.l		#0,d6			* X(0～49)のカウンタ
1:		movea.l		a0,a5			* a5.l = 現在のXのベースアドレス

		move.w		d6,d5
		add.w		d5,d5
		move.w		(a2,d5.w),d5		* d5.w = D (Xに対応する予測値)

		move.w		d5,d4
		muls.w		#7,d4
		lsr.w		#2,d4			* d4.w = D*7/4
		move.w		d4,(a0)+		* D*7/4 (最大△PCM値) 書き込み

		moveq.l		#7,d0
2:		move.w		d0,d1			* Xに対応するヘッダ部分作成
		lsl.w		#4,d1
		or.w		d0,d1
		move.w		d1,(a0)+		* ADPCMデータ 書き込み

		move.w		d0,d1
		add.w		d1,d1
		move.w		d5,d2
		muls.w		(a1,d1.w),d2
		lsr.w		#3,d2
		move.w		d2,(a0)+		* 実際の△PCM 書き込み

		move.w		d6,d2
		add.w		(a3,d1.w),d2
		bpl		@f
		moveq.l		#0,d2
@@:		cmpi.w		#48+1,d2
		bcs		@f
		moveq.l		#48,d2
@@:		add.w		d2,d2
		add.w		d2,d2
		move.l		(a4,d2.w),d1
		sub.l		a0,d1
		move.w		d1,(a0)+		* 次のXアドレスへのオフセット書き込み
		subq.b		#1,d0
		bge		2b


		move.w		d4,d7
		btst.l		#0,d7
		bne		@f
		sub.w		#1,d7			* d7.w = PCM のカウンタ

@@:		moveq.l		#0,d4

2:		move.l		d4,d0			* ヘッダ部分へのオフセット計算
		add.l		d0,d0
		add.l		d0,d0			* d0.l = PCM * 4
		divs.w		d5,d0			* d0.w = PCM*4 / D

		cmpi.w		#$0007+1,d0
		bcs		@f
		moveq.l		#7,d0			* d1 > 7 なら d1=7

@@:		eori.w		#$0007,d0		* 0～7 -> 7～0 に変換
		add.w		d0,d0
		move.w		d0,d1
		add.w		d0,d0
		add.w		d1,d0
		move.b		d0,(a0)+		* オフセット書き込み
		addq.w		#1,d4
		dbra		d7,2b

		addq.w		#1,d6
		cmp.w		#48+1,d6
		bcs		1b

		rts

*===============================================================
* init_mpcm	: 割り込みワーク/ADPCM/DMAの初期化
*===============================================================

init_mpcm:	lea.l		mpw,a6
		jsr		init_channel_work	* 全チャンネルワーク初期化

		clr.l		-(sp)
		DOS		_SUPER
		move.l		d0,(sp)

		move.w		sr,d0			* sr 保存
		ori.w		#$0700,sr		* 割り込み禁止

		move.l		$0084.w,d1		* trap1
		cmp.l		#$00ff0000,d1
		bcs		trap1_error		* 何者かがtrap#1を占有している


		clr.b		ADPCM_SYSWORK.w		* IOCS 初期化

*		ADPCMの初期化
		move.w		frq_offset-mpw(a6),d0
		beq		2f
		cmpi.w		#4*2,d0
		beq		1f
		move.w		#$0203,d1		* ADPCM 7.8kHz
		bra		@f
1:		move.w		#$0403,d1		* ADPCM 15.6kHz
		bra		@f
2:		move.w		#$0603,d1		* ADPCM 31.2kHz
@@:		jsr		ADPCM_mode		* 周波数15.6kHz/PAN左右
		move.b		#$02,ADPCM+1		* ADPCM 再生ON

*		DMA 初期化
@@:		lea.l		DMA3,a0
		move.b		#$04,SCR(a0)		* SCR clear
		move.b		#$10,DCCR(a0)		* CCR DMA停止割り込み無し
		move.b		#$80,DCR(a0)		* DCR clear
		move.b		#$02,OCR(a0)		* OCR clear
		move.b		#$01,CPR(a0)
		move.b		#$05,MFC(a0)
		move.b		#$05,DFC(a0)

*		割り込みベクタのフック
		move.l		$0084.w,trap1_vec_buff	* trap1
		move.l		#mpcm_trap1,$0084.w
		move.l		$01a8.w,DMA_vec_buff	* DMA転送終了割り込み
		move.l		#mpcm,$01a8.w
		move.l		$01ac.w,DMAERR_vec_buff	* DMA転送エラー割り込み
		move.l		#mpcm_err,$01ac.w

		move.w		d0,sr			* 割り込み許可

		lea.l		mplock_app_name-mpw(a6),a0	* mpcm lock app名初期化
		moveq.l		#32-1,d0
@@:		clr.b		(a0)
		lea.l		32(a0),a0
		dbra		d0,@b

		clr.b		mpcm_locked-mpw(a6)

		DOS		_SUPER
		addq.l		#4,sp

		rts

trap1_error:	move.w		d0,sr			* 割り込み許可
		DOS		_SUPER
		addq.l		#4,sp
		bra		error3

*===============================================================
* init_iocs	: IOCS処理ルーチンのエントリ
*===============================================================

init_iocs:	lea.l		iocs_vecs,a2
		move.w		#$0160,d1
		lea.l		mpcm_iocs_60,a1
		IOCS		_B_INTVCS		* IOCS _ADPCMOUTをフック
		move.l		d0,(a2)+		* 前のを保存
		addq.w		#1,d1
		lea.l		mpcm_iocs_61,a1
		IOCS		_B_INTVCS		* IOCS _ADPCMINPをフック
		move.l		d0,(a2)+
		addq.w		#1,d1
		lea.l		mpcm_iocs_62,a1
		IOCS		_B_INTVCS		* IOCS _ADPCMAOTをフック
		move.l		d0,(a2)+
		addq.w		#1,d1
		lea.l		mpcm_iocs_63,a1
		IOCS		_B_INTVCS		* IOCS _ADPCMAINをフック
		move.l		d0,(a2)+
		addq.w		#1,d1
		lea.l		mpcm_iocs_64,a1
		IOCS		_B_INTVCS		* IOCS _ADPCMLOTをフック
		move.l		d0,(a2)+
		addq.w		#1,d1
		lea.l		mpcm_iocs_65,a1
		IOCS		_B_INTVCS		* IOCS _ADPCMLINをフック
		move.l		d0,(a2)+
		addq.w		#1,d1
		lea.l		mpcm_iocs_66,a1
		IOCS		_B_INTVCS		* IOCS _ADPCMSNSをフック
		move.l		d0,(a2)+
		addq.w		#1,d1
		lea.l		mpcm_iocs_67,a1
		IOCS		_B_INTVCS		* IOCS _ADPCMMODをフック
		move.l		d0,(a2)+
		rts

*===============================================================
* recover_iocs	: IOCS処理ルーチンを元に戻す
*===============================================================

recover_iocs:	lea.l		iocs_vecs-header(a5),a2
		move.w		#$0160,d1
		movea.l		(a2)+,a1
		IOCS		_B_INTVCS		* IOCS _ADPCMOUTを戻す
		addq.w		#1,d1
		movea.l		(a2)+,a1
		IOCS		_B_INTVCS		* IOCS _ADPCMINPを戻す
		addq.w		#1,d1
		movea.l		(a2)+,a1
		IOCS		_B_INTVCS		* IOCS _ADPCMAOTを戻す
		addq.w		#1,d1
		movea.l		(a2)+,a1
		IOCS		_B_INTVCS		* IOCS _ADPCMAINを戻す
		addq.w		#1,d1
		movea.l		(a2)+,a1
		IOCS		_B_INTVCS		* IOCS _ADPCMLOTを戻す
		addq.w		#1,d1
		movea.l		(a2)+,a1
		IOCS		_B_INTVCS		* IOCS _ADPCMLINを戻す
		addq.w		#1,d1
		movea.l		(a2)+,a1
		IOCS		_B_INTVCS		* IOCS _ADPCMSNSを戻す
		addq.w		#1,d1
		movea.l		(a2)+,a1
		IOCS		_B_INTVCS		* IOCS _ADPCMMODを戻す
		rts

		.align		4


*===============================================================
* 		非常駐部分固定データ
*===============================================================
		.data

title_mes:	.dc.b		'Modulatable (ad)PCM driver MPCM.x version. 0.45A '
		.dc.b		'copyright (c) 1994,98 by wachoman'
crlf_mes:	.dc.b		CR,LF,0

keep_mes:	.dc.b		'常駐しました.',CR,LF,0
free_mes:	.dc.b		'常駐解除しました.',CR,LF,0

error0_mes:	.dc.b		'常駐していません.',CR,LF,0
error1_mes:	.dc.b		'既に常駐しています.',CR,LF,0
error2_mes:	.dc.b		'占有されているため常駐解除できません.',CR,LF,0
error3_mes:	.dc.b		'TRAP#1が既に使用されています. 常駐できません.',CR,LF,0

usage_mes:	.dc.b		'usage  :  mpcm.x [option]',CR,LF
		.dc.b		'option :  /r      ･････････ 常駐解除',CR,LF
		.dc.b		'          /d[0/1] ･････････ デバッグモード変更',CR,LF
		.dc.b		'          /v      ･････････ 音量16段階固定          (常駐時のみ有効)',CR,LF
		.dc.b		'          /fh     ･････････ ADPCM動作周波数 31.2kHz (常駐時のみ有効)',CR,LF
		.dc.b		'          /fl     ･････････ ADPCM動作周波数  7.8kHz (常駐時のみ有効)',CR,LF
		.dc.b		'          /s      ･････････ mpcm状態表示',CR,LF
		.dc.b		0

change_debugmode_mes:
		.dc.b		'デバッグモードを変更しました.',CR,LF,0
no_lock_entry_mes:
		.dc.b		'MPCMは占有されていません.',CR,LF,0
lock_entry_mes:
		.dc.b		'-- MPCMを占有しているアプリケーション一覧 --',CR,LF,0

debug_mode_mes:	.dc.b		'デバッグモード :',0
adpcm_mode_mes:	.dc.b		'ADPCM動作周波数:',0
pitch_mode_mes:	.dc.b		'音程変換       :',0
volume_mode_mes:.dc.b		'音量変換       :',0
on_mes:		.dc.b		'on',CR,LF,0
off_mes:	.dc.b		'off',CR,LF,0
adpcm7k_mes:	.dc.b		'7.8kHz',CR,LF,0
adpcm15k_mes:	.dc.b		'15.6kHz',CR,LF,0
adpcm31k_mes:	.dc.b		'31.2kHz',CR,LF,0
v16_mes:	.dc.b		'16段階',CR,LF,0
v128_mes:	.dc.b		'128段階',CR,LF,0
p_lock_mes:	.dc.b		'原音固定',CR,LF,0
p_unlock_mes:	.dc.b		'変換可能',CR,LF,0


		.even

*		Oh!X ADPCM データ -> 倍率変換表
conv_tbl0:	.dc.w		  1,   3,   5,   7,   9,  11,  13,  15
		.dc.w		 -1,  -3,  -5,  -7,  -9, -11, -13, -15

*		Oh!X 予測指標(X) -> 予測値(D) 変換表
conv_tbl1:	.dc.w		  16,  17,  19,  21,  23,  25,  28,  31
		.dc.w		  34,  37,  41,  45,  50,  55,  60,  66
		.dc.w		  73,  80,  88,  97, 107, 118, 130, 143
		.dc.w		 157, 173, 190, 209, 230, 253, 279, 307
		.dc.w		 337, 371, 408, 449, 494, 544, 598, 658
		.dc.w		 724, 796, 875, 963,1060,1166,1282,1411
		.dc.w		1552

*		Oh!X ADPCMデータ -> 予測指標修正値 変換表
conv_tbl2:	.dc.w		 -1,  -1,  -1,  -1,   2,   4,   6,   8
		.dc.w		 -1,  -1,  -1,  -1,   2,   4,   6,   8

*		PCM -> ADPCM表 Xに対応する変換表トップアドレス格納バッファ
conv_tbl3:	.dc.l		PtoA_tbl
		.ds.l		48


*===============================================================
* 		非常駐部分ワークエリア
*===============================================================
		.bss

option_flag:	.ds.b		1			* bit 0 : -r option
							* bit 1 : -d
D_option_work:	.ds.b		1			* D option work
		.even
F_option_work:	.ds.w		1			* F option work

.ifdef	DEBUG

ADPCMBUFF:	.ds.b		64*1024

.endif
		.end		mpcm_start
