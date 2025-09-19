<#
enum AuthorizationType {
    Default = 0
    Basic = 1
    PAT = 2
    Bearer = 3
    OAuth = 4
}
#>

Add-Type @'
public enum AuthorizationType {
    Default = 0,
    Basic = 1,
    PAT = 2,
    Bearer = 3,
    OAuth = 4,
}
'@