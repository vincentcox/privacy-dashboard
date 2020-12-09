# script.sh
cd "$(dirname "$0")"
set -u pipefail errexit
## Variables
MAXLINKS=15 #when script ready, increase to 30
WAITMSEC=1000
SOCIALS='"facebook", "hotjar", "google", "trafficjunky", "ads"' # to edit

## easyprivacy list:
#wget -O easyprivacy.txt -q https://justdomains.github.io/blocklists/lists/easyprivacy-justdomains.txt
#cat easyprivacy.txt |tail




## HTML content

read -d '' html_1 << EOF
<!doctype html>
<html lang="en">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">

    <title>Report Privacy</title>
    <style>
html {
  position: relative;
  min-height: 100%;
}
body {
  margin-bottom: 60px;
}

.footer {
  position: absolute;
  bottom: 0;
  width: 100%;
  height: 60px;
  line-height: 60px;
  background-color: #f5f5f5;
}
    </style>
  </head>
  <body>
  <!-- Image and text -->
<nav class="navbar navbar-light bg-light">
  <a class="navbar-brand" href="#">
    <img src="client_logo.png" height="30" class="d-inline-block align-top" alt="" loading="lazy">
    Privacy Report
  </a>
</nav>
  <div class="container">
    <h1>Overview</h1>

    <!-- Optional JavaScript -->
    <!-- jQuery first, then Popper.js, then Bootstrap JS -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js" integrity="sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js" integrity="sha384-9/reFTGAW83EW2RDu2S0VKaIzap3H66lZH81PoYlFhbGU+6BZp6G7niu735Sk7lN" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js" integrity="sha384-B4gt1jrGC7Jh4AgTPSdUtOBvfO8shuf57BaghqFfPlYxofvL8/KUEfYiJOMMV+rV" crossorigin="anonymous"></script>
EOF

read -d '' table_header << EOF
<div class="table-responsive">
    <table class="table">
  <thead class="thead-dark">
    <tr>
      <th scope="col" data-toggle="tooltip" data-placement="top" title="This is the domain name">Domain</th>
      <th scope="col" data-toggle="tooltip" data-placement="top" title="This means: use of HTTPS, redirection of HTTP to HTTPS and not allowing HTTP after redirection.">Correct use of HTTPS</th>
      <th scope="col" data-toggle="tooltip" data-placement="top" title="Wether or not there are a lot of (privacy concerning) 3th party hosts.">3th party hosts violation</th>
      <th scope="col" data-toggle="tooltip" data-placement="top" title="Wether or not there are a lot of (privacy concerning) 3th party beacons.">3th party beacon violation</th>
      <th scope="col" data-toggle="tooltip" data-placement="top" title="Wether or not there are forms being sent over HTTP. These forms can also poin to insecure websites.">Web forms encrypted</th>
      <th scope="col" data-toggle="tooltip" data-placement="top" title="View the full reports via the buttons below.">Full Report</th>
    </tr>
  </thead>
  <tbody>
EOF

read -d '' table_footer << EOF
    </tbody>
   </table>
   </div>
EOF

read -d '' html_2 << EOF
   <h3>Legenda</h3>
   <ul class="list-group">
  <li class="list-group-item"><span class="badge badge-secondary">First-Party</span>: In this document, first-party is a classification of the resources links, web beacons, and cookies. To be first party, the resource domain must match the domain of the inspected web service or other configured first-party domains. Note that the resource path must also be within the path of the web service to be considered first-party.</li>
  <li class="list-group-item"><span class="badge badge-secondary">Third-Party</span>: Links, web beacons and cookies that are not first-party (see above) are classified as third-party.</li>
  <li class="list-group-item"><span class="badge badge-secondary">Web Beacon</span>: A web beacon is one of various techniques used on web pages to unobtrusively (usually invisibly) allow tracking of web page visitors. A web beacon can be implemented for instance as a 1x1 pixel image, a transparent image, or an empty file that is requested together with other resources when a web page is loaded.</li>
</ul>
<p><small>Shamelessly copied from the 'Glossary' section in the report. </small></p>
   </div>
   <footer class="footer">
      <div class="container">
        <span class="text-muted">UI tool built for <a href="https://edps.europa.eu/press-publications/edps-inspection-software_en">Website Evidence Collector</a>. Created by Vincent Cox</span>
      </div>
    </footer>
EOF

html_3='<script>$(function () {$("[data-toggle=tooltip]").tooltip()})</script></body></html>'

TABLE=""
rm -f error
rm -f out
rm -rf output_dir
mkdir output_dir && chmod 777 output_dir


for domain_file in "targets"/*
do
  echo "[---] $(printf '%s\n' "${domain_file//targets\//}") [---]"
    ### go over all subdomains in file (domain_file)
    TABLE=$TABLE"<h3>$(printf '%s\n' "${domain_file//targets\//}")</h3>"
    TABLE=$TABLE$table_header
    while IFS= read -r domain || [[ -n "$domain" ]]; do
        #domain='https://www.suez.com'
        echo "[+++] $domain [+++]"
        domain_html_folder=output_dir/$(echo $domain | tr -cd '[:alnum:]._-')
        domain_json_output=output_dir/$(echo $domain | tr -cd '[:alnum:]._-').output
        #echo "json file: $domain_json_output"
        echo "[+]: Running website evidence collector tool..."
        #trap 'catch' EXIT
        #trap 'catch' ERR
        #trap "{ echo 'Bye!' ; exit 0; }" SIGINT

        #catch() {
        #echo "error code:$?"
        #exit 1
        #}
        touch error

        $(docker run --rm --cap-add=SYS_ADMIN -v $(pwd)/output_dir/:/output/output_dir website-evidence-collector --output /output/$domain_html_folder --overwrite --json -s $WAITMSEC --max $MAXLINKS https://$domain> $domain_json_output > out 2>error) &
        job1pid=$!
        terminate=""
        for i in {1..300}
        do
        # if process is killed, break out
        if [ $(kill -0 $job1pid 2> /dev/null || echo "lala") ]; then break; fi
        ####
        if [[ $(cat error| grep -q "non-zero exit code.") -eq 1 ]]
        then
        {kill $job1pid} 2> /dev/null
        echo "Seems like an error occurred for $domain"
        terminate="YES"
        rm error
        break
        else
        sleep 1
        fi
        done
        if [[ ! -f "$domain_html_folder/inspection.html" ]]
        then
        echo "Seems like no report is available for $domain"
        terminate="YES"
        fi
        if [ "$terminate" == "YES" ]
        then
        TABLE=$TABLE"<tr class=\"table-danger\"><th scope=\"row\" style=\"width:199px;\"><div class=\"text-break\">$domain</div></th><td>N/A</td><td>N/A</td><td>N/A</td><td>N/A</td><td>N/A</td></tr>"

        #cat error
        continue
        fi

        TABLE=$TABLE"<tr><th scope=\"row\" style=\"width:199px;\"><div class=\"text-break\">$domain</div></th>"


        # Correct use of HTTPS
        https_secure=$(cat $domain_html_folder/inspection.json | jq .secure_connection.https_support)
        https_redirect=$(cat $domain_html_folder/inspection.json | jq .secure_connection.https_redirect)
        if [ "$https_secure" == "true" ] && [ "$https_redirect" == "true" ]
        then badge="success"; message="Yes! 🌈";
        else badge="danger"; message="No ❌";
        fi
        tooltip="HTTP allowed: $https_secure, HTTPS redirect: $https_redirect"
        echo "[HTTPS 🔒]: $message"
        TABLE=$TABLE"<td><a href='$domain_html_folder/inspection.html#sec:use-of-httpsssl'><span class=\"badge badge-$badge\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"$tooltip\">$message</span></a></td>"



        # Third party hosts
        # ToDo: check if correct search field (check html output and json position!)
        third_party_count_all=$(cat $domain_html_folder/inspection.json | jq .hosts.requests.thirdParty | jq ".[]" | wc -l | sed 's/ //g')

        third_party_socials_count=$(cat $domain_html_folder/inspection.json | jq .hosts.requests.thirdParty | jq ".[] | contains($SOCIALS)" | grep -c "true")
        # echo $(cat $domain_html_folder/inspection.json | jq .hosts.requests.thirdParty)
        if [ "$third_party_socials_count" -eq 0 ]
        then badge="success"; message="No known violations! 🌈"
        else
            if [ "$third_party_socials_count" -ge 3 ]
            then badge="danger"; message="A LOT violations! 🚨"
            else badge="warning"; message="Several violations!❗️"
            fi
        fi
        tooltip="There are $third_party_socials_count privacy violating parties from the $third_party_count_all total third parties."
        echo "[3th Party 🎉]: $message ($third_party_socials_count/$third_party_count_all)"
        TABLE=$TABLE"<td><a href='$domain_html_folder/inspection.html#sec:traffic-analysis'><span class=\"badge badge-$badge\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"$tooltip\">$message ($third_party_socials_count/$third_party_count_all)</span></a></td>"


        # Beacons
        third_party_beacons_all=$(cat $domain_html_folder/inspection.json | jq .hosts.beacons.thirdParty | jq ".[]" | wc -l | sed 's/ //g')
        third_party_beacons_socials_count=$(cat $domain_html_folder/inspection.json | jq .hosts.beacons.thirdParty | jq ".[] | contains($SOCIALS)" | grep -c "true")
        if [ "$third_party_beacons_socials_count" -eq 0 ]
        then badge="success"; message="No known violations! 🌈"
        else
            if [ "$third_party_beacons_socials_count" -ge 3 ]
            then badge="danger"; message="A LOT violations! 🚨"
            else badge="warning"; message="Several violations!❗️"
            fi
        fi
        tooltip="There are $third_party_beacons_socials_count privacy violating parties from the $third_party_beacons_all total third parties."
        echo "[3th Party beacons 🎉]: $message ($third_party_beacons_socials_count/$third_party_beacons_all)"
        TABLE=$TABLE"<td><a href='$domain_html_folder/inspection.html#app:annex-beacons'><span class=\"badge badge-$badge\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"$tooltip\">$message ($third_party_beacons_socials_count/$third_party_beacons_all)</span></td>"


        # Web Forms unencrypted
        webforms_unencrytped=$(cat $domain_html_folder/inspection.json | jq .unsafeForms)
        if [ "$webforms_unencrytped" == "[]" ]
        then badge="success"; message="Yes 🌈"
        else badge="danger"; message="No ❌"
        fi
        echo "[no unencrypted webforms detected 📝]: $message"
        TABLE=$TABLE"<td><a href='$domain_html_folder/inspection.html#sec:unsecure-forms'><span class=\"badge badge-$badge\">$message</span></a></td>"


        #HTML link page
        html_link_domain="$domain_html_folder/inspection.html"
        echo "[Full Report]: $html_link_domain"
        TABLE=$TABLE"<td><a class=\"btn btn-secondary\" href=\"$html_link_domain\" role=\"button\">Link</a></td>"

        # doesn't work
        echo $html_1$TABLE$table_footer$html_2$html_3>"report.html"
    done <$domain_file
    TABLE=$TABLE$table_footer
    echo $html_1$TABLE$html_2$html_3>"report.html"
    rm -f error
    rm -f out
done
cp report.html /var/www/html/app/report.html
rm -rf /var/www/html/app/output_dir
cp -r output_dir /var/www/html/app/
