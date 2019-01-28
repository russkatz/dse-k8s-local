COPY writeDemo.py /tmp
RUN apt-get update && apt-get install -y \
    python-pip
RUN python -m pip install dse-driver
RUN make /tmp
CMD python /tmp/writeDemo.py > /tmp/output.log
