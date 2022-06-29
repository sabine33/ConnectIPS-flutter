const MERCHANTID = "484";
const APPID = "MER-484-APP-1";
const APPNAME = "Compro Computers Pvt. Ltd.";
const TXNCRNCY = "NPR";

const VERIFICATION_URL =
    "https://uat.connectips.com:7443/connectipswebws/api/creditor/validatetxn";

const BASEURL = "https://uat.connectips.com:7443/connectipswebgw/loginpage";

const VERIFICATION_ID = "MER-XXX-APP-XXX";

const VERIFICATION_PASSWORD = '';

const CALLBACKURL = "https://hajurbuy.com/pay/via/connectips/callback";

const ERRORURL = "https://uat.connectips.com:7443/connectipswebgw/errorpage";

const HOMEURL = "https://uat.connectips.com:7443/connectipswebgw/home";

const HOMERROR =
    "https://uat.connectips.com:7443/connectipswebgw/home?isoerror";

const UNAUTHERROR = "https://uat.connectips.com:7443/connectipswebgw/403";

String privateKeyPEM = """
-----BEGIN PRIVATE KEY-----
...
-----END PRIVATE KEY-----
""";
