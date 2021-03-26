all: $(patsubst %.txt,%.dump,$(wildcard *.txt))

%.dump: %.txt
	utmpdump -r < $< -o $@
