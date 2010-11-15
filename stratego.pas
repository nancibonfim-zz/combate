{
Trabalho final de MATA37 - Equipe 1: Jean, Luisa e Nanci
Projeto: Combate
}

program stratego;
uses CRT;

type
   no_pecas = ^pecas;
   pecas  = record {lista de peças}
               nome : string[13];
               rank : integer; {rank da peça - vai de 0 a 11}
               prox : no_pecas;
            end;
   
var
   inicio, lago : no_pecas;
   tabuleiro    : array [1..10, 1..10] of ^pecas;
   jogadores    : array [1..2, 0..11] of integer;
   n            : integer;
   
{Criação da lista de peças}
procedure lista_pecas(var inicio : no_pecas; n : string; r : integer);
var aux1, aux2 : no_pecas;
begin
   new(aux1);
   aux1^.nome := n;
   aux1^.rank := r;
   if (inicio = nil) then
      inicio := aux1
   else
   begin
      aux2 := inicio;
      while (aux2^.prox <> nil) do
         aux2 := aux2^.prox;
      aux2^.prox := aux1;
   end;
end; { lista_pecas }

{O procedimento a seguir insere os dados das peças do jogo na lista}
procedure dados_pecas;
begin
   lista_pecas(inicio, 'bomba', 0);
   lista_pecas(inicio, 'espiao', 1);
   lista_pecas(inicio, 'soldado', 2);
   lista_pecas(inicio, 'cabo-armeiro', 3);
   lista_pecas(inicio, 'sargento', 4);
   lista_pecas(inicio, 'tenente', 5);
   lista_pecas(inicio, 'capitao', 6);
   lista_pecas(inicio, 'major', 7);
   lista_pecas(inicio, 'coronel', 8);
   lista_pecas(inicio, 'general', 9);
   lista_pecas(inicio, 'marechal', 10);
   lista_pecas(inicio, 'bomba', 11);
end; { dados_pecas }

{Procedimento para preencher os vetores dos jogadores com as quantidades de cada peça -> as funções devem alterar esse valor}
procedure pecas_jogadores;
var i  : integer;
begin
   jogadores[1][0] := 1;
   jogadores[1][1] := 1;
   jogadores[1][2] := 8;
   jogadores[1][3] := 5;
   jogadores[1][4] := 4;
   jogadores[1][5] := 4;
   jogadores[1][6] := 4;
   jogadores[1][7] := 3;
   jogadores[1][8] := 2;
   jogadores[1][9] := 1;
   jogadores[1][10] := 1;
   jogadores[1][11] := 6;
   for i:=0 to 11 do
      jogadores[2][i] := jogadores[2][i];
end; { pecas_jogadores }

{função apenas de teste, para ver se a lista tava funcionando de boa}
procedure teste_imprime;
var aux : ^pecas;
begin
   aux := inicio;
   while (aux <> nil) do
   begin
      writeln(aux^.nome);
      writeln(aux^.rank);
      aux := aux^.prox;
   end;
end; { teste_imprime }

{Explicações/Adionais:

No jogo, na hora de dispor as peças no tabuleiro e mover as peças é usada a lista e a lista passa a referencia para o vetor de cada jogador. Então na função de dispor as peças e de mover as peças é necessário uma variavel auxiliar do tipo no_pecas (ponteiro para a lista).

Pensei em relação as configurações da peça no tabuleiro:
1 - um procedimento com case pra imprimir e chamar as opções
2 - uma função para disposição das peças, que pegaria o valor do case como parametro e mandaria a disposicao que o usuario escolhesse ou um procedimento para cada disposicao e o case chamaria o procedimento correspondente.
lembrando, são 40 peças... talvez fique grande demais em uma função só, ou não.. ainda não sei e aceito sugestões.

Ja ia esquecendo... a bomba não entra no vetor de peças dos jogadores. Como é só uma, não ataca, não mata e não move é desnecessário para o objetivo.
}

{Procedimento para dispor as peças de determinado jogador (a ou b) no tabuleiro}
procedure dispor_pecas(x : integer );
var q, linha, coluna, rank : integer;
   cheq                    : boolean;
   aux                     : no_pecas;
begin
   q := 0;
   repeat
      aux := inicio;
      writeln('Digite o rank de uma peça. Use 11 para bomba e 0 para bandeira');
      readln(rank);
      {Se o jogador digitar um rank inválido ele terá que digitar novamente}
      while (jogadores[x][rank] = 0) or (rank < 0) or (rank > 12) do
      begin
         writeln('Peça indisponível. Por favor, digite novamente o rank');
         readln(rank);
      end;
      {A auxiliar vai percorrer a lista até achar o rank correspondente}
      while (aux^.rank <> rank) and (aux <> nil) do
      begin
         aux := aux^.prox;
      end;
      cheq := false; {Variável para verificar se o jogador digitou uma posição válida no tabuleiro}
      repeat   
         writeln('Digite a posição da peça');
         readln(linha, coluna);
         if (x = 1) then
         begin
            if (linha < 0) or (linha > 4) then
               writeln('Posição inválida')
            else
               cheq := true;
         end
         else
            if (linha > 20) or (linha < 17) then
               writeln('Posição inválida')
            else
               cheq := true;
      until (cheq = true);
      tabuleiro[linha][coluna] := aux;
      dec(jogadores[x][rank]); {Decrementa o número de peças disponíveis}
      inc(q);
      imprime_tabuleiro;
   until (q = 2); {XXX: q = 40}
end; { dispor_pecas }

procedure preenche_lago;
begin
   tabuleiro[5][3] := lago;
   tabuleiro[5][4] := lago;
   tabuleiro[6][3] := lago;
   tabuleiro[6][4] := lago;
   tabuleiro[5][7] := lago;
   tabuleiro[5][8] := lago;
   tabuleiro[6][7] := lago;
   tabuleiro[6][8] := lago;
end; { preenche_lago }

procedure imprime_tabuleiro;
var i, j : integer;
begin
   for i := 1 to 10 do
   begin
      for j := 1 to 10 do
         if (tabuleiro[i][j] = nil) then
            write('__ ')
         else
            if (tabuleiro[i][j] = lago) then
               write('XX ')
            else
               write(tabuleiro[i][j]^.rank:2, ' ');
      writeln;
   end;
end; { imprime_tabuleiro }

{Programa principal}
begin
   {preenchimento da área do lago... como temos uma matriz de ponteiros, temos um ponteiro para o lago ser inserido no tabuleiro}
   new(lago);
   lago^.rank := -1;
   lago^.nome := 'lago';
   preenche_lago;

   dados_pecas;
   pecas_jogadores;
   n := 1;
   dispor_pecas(n);
   imprime_tabuleiro;
end.