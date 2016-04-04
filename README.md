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
