#! /bin/bash

if [[ -z "${S_Path}" ]]; then
  S_Path="/black-box"
fi

if [[ -z "${S_Method}" ]]; then
  S_Method="aes-256-gcm"
fi

if [[ -z "${S_PW}" ]]; then
  S_PW="herokushadow"
fi

date -R

mkdir /var/tmp/nginx
mkdir /wwwroot

CONF1=$(cat /home/Software/1.conf)
CONF2=$(cat /home/Software/2.conf)

echo -e -n "${CONF1}" > /etc/nginx/conf.d/default.conf
echo -e -n "${S_Path}" >> /etc/nginx/conf.d/default.conf
echo -e -n "${CONF2}" >> /etc/nginx/conf.d/default.conf

sed -i -E "s/Docker_PORT/${PORT}/" /etc/nginx/conf.d/*.conf
sed -i -E "s/^;listen.owner = .*/listen.owner = $(whoami)/" /etc/php7/php-fpm.d/www.conf
sed -i -E "s/^user = .*/user = $(whoami)/" /etc/php7/php-fpm.d/www.conf
sed -i -E "s/^group = (.*)/;group = \1/" /etc/php7/php-fpm.d/www.conf
sed -i -E "s/^user .*/user $(whoami);/" /etc/nginx/nginx.conf


wget --no-check-certificate -qO '/tmp/demo.tar.gz' "https://github.com/Dark11296/sk-plugin-heroku/raw/master/demo.tar.gz"
wget --no-check-certificate -qO '/tmp/v2ray-plugin.tar.gz' "https://github.com/Dark11296/sk-plugin-heroku/raw/master/v2ray-plugin-linux-$SYS_Bit.tar.gz"

tar xvf /tmp/demo.tar.gz -C /wwwroot
tar xvf /tmp/v2ray-plugin.tar.gz -C /home/Software
chmod +x /home/Software/*

cat <<-EOF > /home/Software/ss.json
{
    "server":"0.0.0.0",
    "server_port":8080,
    "local_port":1080,
    "password":"${S_PW}",
    "Method":"${S_Method}",
    "mode":"tcp_only",
    "timeout":300,
    "plugin":"/home/Software/v2ray-plugin_linux",
    "plugin_opts":"server;mode=websocket;path=${S_Path};loglevel=none"
}
EOF

ss-server -c /home/Software/ss.json &
supervisord --nodaemon --configuration /etc/supervisord.conf
