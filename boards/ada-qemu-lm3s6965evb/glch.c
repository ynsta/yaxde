extern void put_char(char c);
extern void put_int(int i);
extern void _halt(void);

void __gnat_last_chance_handler (char *source_location, int line)
{
    char *p = source_location;
    while (p && *p)
        put_char(*p++);
    put_char(':');
    put_int(line);
    put_char('\n');
    _halt();
}
