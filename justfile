default:
    just --list

prepare:
    zigup 0.13.0

build: 
    zig build

run:
    zig build run

test: 
    zig build test

clean:
    rm -r ./.zig-cache ./zig-out
