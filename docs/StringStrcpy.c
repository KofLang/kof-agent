
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
	char palavra1[100] = {"Ola mundo!"};
	char palavra2[100];
	
	printf("\n\tPalavra1: %s\n", palavra1);
	printf("\n\tPalavra2: %s\n", palavra2);
	
	strcpy(palavra2, palavra1); // onde por a copia , de onde copiar.
	
	printf("\n\tPalavra1: %s\n", palavra1);
	printf("\n\tPalavra2: %s\n", palavra2);
	
	return 0;
}

