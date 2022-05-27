#!/bin/bash

for i in {1..20}; do 
	logger -n 192.168.1.11 ${STRING}${i}
done
