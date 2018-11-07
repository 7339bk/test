Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms

<#
.Synopsis
   実行中の任意のプロセスにキーストロークを送る操作をします。
.DESCRIPTION
   パラメータのキーストローク、プロセス名がそれぞれ未指定の場合、何も実行されません。
   キーストロークのみが指定された場合は実行時のフォーカスへキーストロークを送り、
   プロセス名のみが指定された場合はフォーカスのみが指定されたプロセスに変更します。
.EXAMPLE
   Send-Keys -KeyStroke "test.%~" -ProcessName "LINE"

   このコマンドは既に起動中のLINEアプリに対して"test."と入力し、
   Altキーを押しながらEnterキーを押下する操作をしています。
#>
function Send-Keys
{
    [CmdletBinding()]
    [Alias("sdky")]
    Param
    (
        # キーストローク
        # アプリケーションに送りたいキーストローク内容を指定します。
        # キーストロークの記述方法は下記のWebページを参照。
        # https://msdn.microsoft.com/ja-jp/library/cc364423.aspx
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $KeyStroke,

        # プロセス名
        # キーストロークを送りたいアプリケーションのプロセス名を指定します。
        # 複数ある場合は、PIDが一番低いプロセスを対象とする。
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $ProcessName,

        # 待機時間
        # コマンドを実行する前の待機時間をミリ秒単位で指定します。
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [int]
        $Wait = 0
    )

    Process
    {
        $Process = ps | ? {$_.Name -eq $ProcessName} | sort -Property CPU -Descending | select -First 1
        Write-Verbose $Process", KeyStroke = "$KeyStroke", Wait = "$Wait" ms."
        sleep -Milliseconds $Wait
        if ($Process -ne $null)
        {
            [Microsoft.VisualBasic.Interaction]::AppActivate($Process.ID)
        }
        [System.Windows.Forms.SendKeys]::SendWait($KeyStroke)
    }
}
Add-Type -AssemblyName System.Windows.Forms
for ($i = 0; $i -lt 10; $i++) {
    Send-Keys "$("^(ac)" * 1)" -ProcessName "mspaint"    <#change process-name#>
    $checkImage = [Windows.Forms.Clipboard]::GetImage()
    if ($null -ne $checkImage){Send-Keys "," -ProcessName "mspaint"} <#change process-name#>
    Send-Keys "$("^(c){TAB}" * 1)" -ProcessName "excel"
    start-sleep -m 500
    $clipboardImage = [Windows.Forms.Clipboard]::GetImage()
    if ($null -eq $clipboardImage){break}
    Send-Keys "$("^(v)" * 1)" -ProcessName "mspaint"    
}