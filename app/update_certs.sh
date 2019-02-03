#!/usr/bin/env sh

_OUTPUT_="$0"

acme() {
    printf "\nreloading tengine with old configuration\n"
    nginx -t && nginx -s reload

    printf "\nchecking if there is any server requiring SSL\n"
    if grep ACME_DOMAINS /etc/nginx/conf.d/default.conf
    then
        for d_list in $(grep ACME_DOMAINS /etc/nginx/conf.d/default.conf | cut -d ' ' -f 2);
            do
                d=$(echo "$d_list" | cut -d , -f 1)

                printf "\ngetting certificates for $d_list\n"
                /acme.sh/acme.sh --home /acme.sh --config-home /acmecerts --issue \
                -d $d_list \
                --nginx \
                --fullchain-file "/etc/nginx/certs/$d.crt" \
                --key-file "/etc/nginx/certs/$d.key" \
                --reloadcmd "nginx -t && nginx -s reload"
            done

        printf "\napplying new tengine configuration\n"
        docker-gen /app/default.conf /etc/nginx/conf.d/default.conf
    else
        printf "\nno servers requiring SSL, skipping acme.sh\n"
    fi

    printf "\nreloading tengine with new configuration\n"
    nginx -t && nginx -s reload
}

"$@"
