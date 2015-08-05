FROM ubuntu:14.04

ENV NAGIOSADMIN_USER nagiosadmin
ENV NAGIOSADMIN_PASS nagios
ENV POSTFIX_DOMAIN nagios.localhost
ENV SMTP_SERVER smtp.gmail.com
ENV SMTP_PORT 587
ENV SMTP_USER user@gmail.com
ENV SMTP_PASS password
ENV DEBIAN_FRONTEND=noninteractive

RUN echo "postfix postfix/mailname string $POSTFIX_DOMAIN" | debconf-set-selections
RUN echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections

RUN echo exit 101 > /usr/sbin/policy-rc.d
RUN chmod +x /usr/sbin/policy-rc.d

RUN apt-get update && apt-get install -y nagios3 nagios-nrpe-plugin ca-certificates

RUN htpasswd -cb /etc/nagios3/htpasswd.users $NAGIOSADMIN_USER $NAGIOSADMIN_PASS

# configure relayhost for notification
RUN echo "[$SMTP_SERVER]:$SMTP_PORT $SMTP_USER:$SMTP_PASS" > /etc/postfix/sasl_passwd 
RUN postmap /etc/postfix/sasl_passwd && chmod 400 /etc/postfix/sasl_passwd
RUN sed -i "s/relayhost =/relayhost = [$SMTP_SERVER]:$SMTP_PORT/" /etc/postfix/main.cf
RUN echo 'smtp_sasl_auth_enable = yes\n\
smtp_sasl_security_options = noanonymous\n\
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd\n\
smtp_use_tls = yes\n\
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt\n'\
>> /etc/postfix/main.cf
RUN /etc/init.d/postfix reload

VOLUME /etc/nagios3
VOLUME /usr/lib/nagios/plugins 

CMD /etc/init.d/apache2 start; \
    /etc/init.d/nagios3 start; \
    /etc/init.d/postfix start; \
    tailf /var/log/nagios3/nagios.log
