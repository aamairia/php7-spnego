<?php
//Ce code fonctionne et est testé sur IE et firefox
function getHeader($header)
{
    $headers = apache_request_headers();
    if (isset($headers[$header])) {
        return $headers[$header];
    }
    $header = strtolower($header);
    foreach ($headers as $key => $value) {
        if (strtolower($key) == $header) {
            return $value;
        }
    }
}

session_start();
if (isset($_SESSION['user'])) {
    echo 'auth done before, current user is: ', $_SESSION['user'];
    exit;
}

$authorization = trim(getHeader('Authorization'));
if (!$authorization) {
    header('HTTP/1.1 401 Unauthorized');
    header('WWW-Authenticate: Negotiate');
    exit;
}

$auth = new KRB5NegotiateAuth('krb5.keytab');
if(!$auth->doAuthentication($authorization)) {
    echo "auth failed";
    exit;
}

$_SESSION['user'] = $auth->getAuthenticatedUser();
echo "auth ok, you are ", $_SESSION['user'];
