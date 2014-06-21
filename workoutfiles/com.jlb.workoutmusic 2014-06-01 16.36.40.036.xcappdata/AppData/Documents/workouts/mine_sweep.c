#include <stdio.h>
#include <stdlib.h> 
#include <string.h>

int count_columns(char * string) {
    
    int count = 0; 
    const int columns_default = strlen(string); 
    int index = 0;
    while (index < columns_default)  {
        char c = string[index]; 
        if (c == '\n') {
           break; 
        } else if ( c != ' ') { 
            count++; 
        }
        index++; 
    }
    return count; 
}

int count_rows(char * string, int columns) {
    
     
    int row_count = 0;
    int row_index = 0; 
    int length = strlen(string);
    while (row_index < length) {
        row_index+=columns+(columns -1);
        row_count++; 
    } 
    return row_count - 1; 
}

void make_matrix(const char * input, char ** matrix, int columns) {
    printf(" make_matrix \n ");
    int index = 0; 
    int column_index = 0; 
    int row_index = 0; 
    int length = strlen(input); 

    while (index < length) { 
        char c = input[index++]; 
        if (c == ' ' || c == '\n') index++; 
        else { 
            if (column_index == columns) {
                column_index = 0; 
                row_index++;
            } 
            matrix[row_index][column_index] = c;
            column_index++; 
        } 
    }
}
     
void print_matrix(char ** matrix, int rows, int columns) {
    for (int i=0; i < rows; i++) { 
        for (int j = 0; j < columns; j++) { 
            printf("%c ", matrix[i][j]); 
        }
        printf("\n");
    }
}

int main() {
    
    char * input = "O O O O X O O O O O\nX X O O O O O O X O\nO O O O O O O O O O\nO O O O O O O O O O\nO O O O O X O O O O";    
    int columns = count_columns(input); 
    int rows = count_rows(input,columns); 
    printf("%s", input);
   
    

   char ** matrix = malloc(sizeof(char)*rows*columns); 
    make_matrix(input,matrix,columns); 
    print_matrix(matrix,rows,columns); 

}