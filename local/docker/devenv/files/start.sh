#!/usr/bin/env bash
echo nameserver 1.1.1.1 > /etc/resolv.conf
echo nameserver 1.0.0.1 >> /etc/resolv.conf
while true; do sleep 1; done

