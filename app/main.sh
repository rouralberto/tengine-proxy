#!/usr/bin/env sh

_SCRIPT_="$0"

update_certs() {
  nginx -t && nginx -s reload
  if grep ACME_DOMAINS /etc/nginx/conf.d/default.conf ; then
    for d_list in $(grep ACME_DOMAINS /etc/nginx/conf.d/default.conf | cut -d ' ' -f 2);
    do
      d=$(echo "$d_list" | cut -d , -f 1)
      /acme.sh/acme.sh --home /acme.sh --config-home /acmecerts --issue \
      -d $d_list \
      --nginx \
      --fullchain-file "/etc/nginx/certs/$d.crt" \
      --key-file "/etc/nginx/certs/$d.key" \
      --reloadcmd "nginx -t && nginx -s reload"
    done

     # Generate Tengine `default.conf` again.
    echo "updating tengine config..."
    docker-gen /app/default.conf /etc/nginx/conf.d/default.conf
  else
    echo "skipping update_certs..."
  fi
  echo "restarting tengine to apply changes..."
  nginx -t && nginx -s reload
}

"$@"
