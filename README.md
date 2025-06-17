This is a quick and dirty set of scripts to fuzz [FORM].
To make it work:
- Build [AFL++] using `sh build-afl.sh`.
- Build [FORM] using `sh build-form.sh`.
- Prepare seeds with `python3 mk-seeds.sh`.
- Prepare dictionary with `python3 mk-dict.sh`.
- Start the fuzzers with `sh start-fuzzers.sh`.
- Wait. Check /tmp/fuzz.

[FORM]: https://github.com/form-dev/form/
[AFL++]: https://github.com/AFLplusplus/AFLplusplus/
