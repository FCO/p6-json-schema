FROM rakudo-star

RUN panda update && panda --notests install JSON5::Tiny

ADD . /code
WORKDIR /code

CMD perl6 -I. test.p6
