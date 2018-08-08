  + grep.pl

    ```shell
    grep.pl [-A after_num] [-B before_num] perl_pattern [file..]
    ```

      - grep recursively with perl_pattern

      - output format:

        ```text
        path:line_num:line_content
        ```

      - follow symlinks

      - avoid grep same files by inode number

      - grep only git tracked files if it's in a git repo.

  + brightness.c

    ```shell
    brightness up
    brightness down
    brightness [brightness number]
    ```

    A binary program for setuid.

  + run\_after.pl

    ```shell
    run_after.pl pid cmds...
    ```

      - run shell cmds after process pid endded.
