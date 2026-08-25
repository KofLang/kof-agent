
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
	char vet1[50] = {"Ola"};
	char vet2[50] = {"mundo"};
	
	printf("\n\tvet1 = %s\n", vet1);
	printf("\tvet2 = %s\n", vet2);
	
	strcat(vet1, vet2); // ela pega a segunda string e concatena na primeira string
	
	printf("\n\tvet1 = %s\n", vet1);
	printf("\tvet2 = %s\n", vet2);
	
	return 0;
}

