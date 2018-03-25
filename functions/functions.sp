stock StrToLowerRemoveBlanks(const String:str[], String:buffer[], bufsize)
{
	new n=0, x=0;
	while (str[n] != '\0' && x < (bufsize-1))
	{
		new chr = str[n++];
		if (chr == ' ')
		{
			continue;
		}
		else if (IsCharUpper(chr))
		{
			chr = CharToLower(chr);
		}
		buffer[x++] = chr;
	}
	buffer[x++] = '\0';
	
	return x;
}
