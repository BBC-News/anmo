FROM ruby

RUN gem install anmo
ADD run.sh /run.sh
RUN chmod u+x /run.sh

EXPOSE 9999

CMD ["./run.sh"]
