
# Retrieve the Relying Party
$relyingpartyname = "ClaimsXray"
$relyingparty = Get-ADFSRelyingPartyTrust -Name "$relyingpartyname"
 
# Create Issuance Transform Rules
$issuancerules = New-AdfsClaimRuleSet -ClaimRule @'

@RuleTemplate = "LdapClaims"
@RuleName = "Send Active Directory Claims"
c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"]
 => issue(store = "Active Directory", types = ("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress", "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn"), query = ";mail,userPrincipalName;{0}", param = c.Value);

@RuleName = "Query Group Memberships"
c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"]
=> add(store = "Active Directory", types = ("http://schemas.microsoft.com/custom/groups"), query = ";memberOf;{0}", param = c.Value);

@RuleName = "Construct Group Memberships"
c:[Type == "http://schemas.microsoft.com/custom/groups"]
=> add(Type = "http://schemas.microsoft.com/custom/groupsclean", Value = RegExReplace(c.Value, ",[^\n]*", ""));

@RuleName = "Issue Group Memberships"
c:[Type == "http://schemas.microsoft.com/custom/groupsclean"]
=> issue(Type = "http://schemas.microsoft.com/ws/2008/06/identity/claims/role", Value = RegExReplace(c.Value, "^CN=", ""));

@RuleTemplate = "PassThroughClaims"
@RuleName = "Name ID"
c:[Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier", Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/format"] == "urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified"]
 => issue(claim = c);

@RuleTemplate = "PassThroughClaims"
@RuleName = "Name"
c:[Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"]
 => issue(claim = c);

@RuleName = "Email Address"
c:[Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"]
 => issue(Type = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress", Value = c.Value);

@RuleName = "Windows Account from Lookup"
c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/duid"]
 => issue(store = "Active Directory", types = ("https://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn", "https://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname"), query = "extensionAttribute2={0};userPrincipalName,sAMAccountName;{1}", param = c.Value, param = "LM\aadcsvc$");

@RuleName = "Duid Lookup to get Group Membership"
c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/duid"]
 => issue(store = "Active Directory", types = ("http://schemas.microsoft.com/custom/groups"), query = "extensionAttribute2={0};memberOf;{1}", param = c.Value, param = "LM\aadcsvc$");

@RuleName = "Construct Custom Group Claim"
c2:[Type == "http://schemas.microsoft.com/custom/groups"]
 => add(Type = "http://schemas.microsoft.com/custom/groupsclean", Value = RegExReplace(c2.Value, ",[^\n]*", ""));

@RuleName = "Roles"
c3:[Type == "http://schemas.microsoft.com/custom/groupsclean"]
 => issue(Type = "http://schemas.microsoft.com/ws/2008/06/identity/claims/role", Value = RegExReplace(c3.Value, "^CN=", ""));

@RuleName = "SharePoint UPN Claim"
c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname"]
 => issue(Type = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn", Value = "i:0#.w|" + c.Value, ValueType = c.ValueType);

'@
 
# Apply Issuance Rules to Relying Party
Set-ADFSRelyingPartyTrust `
    -TargetName $relyingparty.Name `
    -IssuanceTransformRules $issuancerules.ClaimRulesString