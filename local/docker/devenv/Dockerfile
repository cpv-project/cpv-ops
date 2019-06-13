FROM ubuntu:18.04

RUN useradd -s /bin/bash -m ubuntu
RUN ln -sf /dev/null /root/.bash_history
RUN ln -sf /dev/null /home/ubuntu/.bash_history
COPY ./files /
RUN chown -R ubuntu:ubuntu /home/ubuntu

RUN apt-get update
RUN apt-get install -y ca-certificates
RUN update-ca-certificates

RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:compiv/cpv-project
RUN apt-get update
RUN apt-get install -y \
	git vim cppcheck gdb devscripts iproute2 \
	seastar ninja-build cqldriver \
	libgtest-dev libubsan1 libasan5 patchelf \
	libhttp-parser-dev

CMD ["sh", "/start.sh"]
