
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
	char palavra1[100] = {"Abacate"};
	char palavra2[100] = {"Abacate"};
	int resultado;
	
	resultado = strcmp(palavra1, palavra2); // comparaçao de strings
	
	printf("\n\tResultado: %d\n", resultado);
	
	
	return 0;
}

