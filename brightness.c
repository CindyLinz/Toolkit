#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <ctype.h>
#include <stdlib.h>
#include <errno.h>

static inline bool all_digits(const char * str){
    if( !*str )
        return false;
    while( *str ){
        if( !isdigit(*str) )
            return false;
        ++str;
    }
    return true;
}

static inline int in(const char * path){
    FILE * f = fopen(path, "r");
    if( !f ){
        printf("read from %s failed: %s\n", path, strerror(errno));
        return -1;
    }

    int data;
    fscanf(f, "%d", &data);
    fclose(f);
    return data;
}

static inline void out(const char * path, int data){
    FILE * f = fopen(path, "w");
    if( !f ){
        printf("write to %s failed: %s\n", path, strerror(errno));
        return;
    }

    fprintf(f, "%d\n", data);
    fclose(f);
}

int main(int argc, char * argv[]){
    int max = in("/sys/class/backlight/intel_backlight/max_brightness");
    int curr = in("/sys/class/backlight/intel_backlight/brightness");
    int next = curr;

    if( argc >= 2 && strcmp(argv[1], "up")==0 ){
        int delta = 1;
        if( argc >= 3 )
            delta = atoi(argv[2]);
        if( curr + delta <= max )
            next = curr + delta;
        else
            next = max;
    }
    else if( argc >= 2 && strcmp(argv[1], "down")==0 ){
        int delta = 1;
        if( argc >= 3 )
            delta = atoi(argv[2]);
        if( curr - delta >= 0 )
            next = curr - delta;
        else
            next = 0;
    }
    else if( argc >= 2 && all_digits(argv[1]) ){
        int req = atoi(argv[1]);
        if( req <= max )
            next = req;
    }
    while( next!=curr ){
        curr += (next - curr)/500;
        if( curr < next )
            ++curr;
        else
            --curr;
        out("/sys/class/backlight/intel_backlight/brightness", curr);
        printf("brightness = %d/%d\r", curr, max);
    }
    printf("brightness = %d/%d\n", in("/sys/class/backlight/intel_backlight/brightness"), max);
    return 0;
}
