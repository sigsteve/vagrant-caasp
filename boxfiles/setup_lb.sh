#!/bin/bash 
source /vagrant/caasp_env.conf

cat > /etc/nginx/nginx.conf << EOF
user  nginx;
worker_processes  auto;

load_module /usr/lib64/nginx/modules/ngx_stream_module.so;

error_log  /var/log/nginx/error.log;
error_log  /var/log/nginx/error.log  notice;
error_log  /var/log/nginx/error.log  info;

events {
    worker_connections  1024;
    use epoll;
}

stream {
    log_format proxy '$remote_addr [$time_local] '
                     '$protocol $status $bytes_sent $bytes_received '
                     '$session_time "$upstream_addr"';

    error_log  /var/log/nginx/k8s-masters-lb-error.log;
    access_log /var/log/nginx/k8s-masters-lb-access.log proxy;

    upstream k8s-masters {
EOF
for NUM in $(seq 1 $NMASTERS); do
    printf "        server caasp4-master-${NUM}:6443 weight=1 max_fails=1;\n" >> /etc/nginx/nginx.conf
done
printf "    }\n" >> /etc/nginx/nginx.conf
printf "    upstream k8s-workers_http {\n" >> /etc/nginx/nginx.conf
for NUM in $(seq 1 $NWORKERS); do
    printf "        server caasp4-worker-1:80 weight=1 max_fails=1;\n" >> /etc/nginx/nginx.conf
done
printf "    }\n" >> /etc/nginx/nginx.conf

printf "    upstream k8s-workers_https {\n" >> /etc/nginx/nginx.conf
for NUM in $(seq 1 $NWORKERS); do
    printf "        server caasp4-worker-1:443 weight=1 max_fails=1;\n" >> /etc/nginx/nginx.conf
done
cat >> /etc/nginx/nginx.conf << EOF
    }

    server {
        listen 6443;
        #proxy_connect_timeout 1s;
        #proxy_timeout 3s;
        proxy_pass k8s-masters;
    }

   server {
        listen 80;
        proxy_pass k8s-workers_http;
    }

    server {
        listen 443;
        proxy_pass k8s-workers_https;
    }

}
EOF

systemctl enable --now nginx
