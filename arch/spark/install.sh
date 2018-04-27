#!/bin/bash

HADOOP_SH="/etc/profile.d/hadoop.sh"


printf "\n===> Installing hadoop\n\n"

yaourt -S hadoop
sed -e "s/SLAVES/WORKERS/" $HADOOP_SH | sudo tee $HADOOP_SH > /dev/null
sed -e "s/slaves/workers/" $HADOOP_SH | sudo tee $HADOOP_SH > /dev/null


printf "\n===> Installing spark\n\n"

yaourt -S apache-spark

