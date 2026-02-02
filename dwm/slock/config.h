/* user and group to drop privileges to */
static const char *user  = "nobody";
static const char *group = "nogroup";

/* Tokyo Night colors */
static const char *colorname[NUMCOLS] = {
	[INIT] =   "#1a1b26",   /* after initialization - bg */
	[INPUT] =  "#7aa2f7",   /* during input - blue */
	[FAILED] = "#f7768e",   /* wrong password - red */
};

/* treat a cleared input like a wrong password (color) */
static const int failonclear = 1;
