{
Trabalho final de MATA37 - Equipe 1: Jean, Luisa e Nanci
Projeto:Combate
}

program stratego;
uses CRT;

type
   no_pecas = ^pecas;
   pecas = record {lista de peças}
              nome    : string[13];
              rank    : integer; {rank da peça - vai de 0 a 11}
              qtde    : integer;
              jogador : integer;
              prox    : no_pecas;
           end;       
   
var
   tabuleiro        : array [1..10, 1..10] of no_pecas;
   controle_pecas   : array [0..11] of integer;
   jog1, jog2, lago : no_pecas;
   
{Criação da lista de peças}
procedure lista_pecas(var inicio : no_pecas; nome : string; rank, jogador : integer);
var aux1, aux2 : no_pecas;
begin
   new(aux1);
   aux1^.nome := nome;
   aux1^.rank := rank;
   aux1^.jogador := jogador;
   aux1^.qtde := 0; {quantidade posicionada de peças -> começa com 0}
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
procedure dados_pecas(inicio : no_pecas; jogador : integer);
begin
   lista_pecas(inicio, 'bomba', 0, jogador);
   lista_pecas(inicio, 'espiao', 1, jogador);
   lista_pecas(inicio, 'soldado', 2, jogador);
   lista_pecas(inicio, 'cabo-armeiro', 3, jogador);
   lista_pecas(inicio, 'sargento', 4, jogador);
   lista_pecas(inicio, 'tenente', 5, jogador);
   lista_pecas(inicio, 'capitao', 6, jogador);
   lista_pecas(inicio, 'major', 7, jogador);
   lista_pecas(inicio, 'coronel', 8, jogador);
   lista_pecas(inicio, 'general', 9, jogador);
   lista_pecas(inicio, 'marechal', 10, jogador);
   lista_pecas(inicio, 'bomba', 11, jogador);
end; { dados_pecas }

{Procedimento que preenche o vetor de controle com as quantidades máximas de cada peça}
procedure pecas_jogadores;
begin
   controle_pecas[0] := 1;
   controle_pecas[1] := 1;
   controle_pecas[2] := 8;
   controle_pecas[3] := 5;
   controle_pecas[4] := 4;
   controle_pecas[5] := 4;
   controle_pecas[6] := 4;
   controle_pecas[7] := 3;
   controle_pecas[8] := 2;
   controle_pecas[9] := 1;
   controle_pecas[10] := 1;
   controle_pecas[11] := 6;
end; { pecas_jogadores }

{Procedimento para alocar no tabuleiro o lago, que é uma área intransitável}
procedure preenche_lago;
begin
   new(lago);
   lago^.rank := -1;
   lago^.nome := 'lago';
   lago^.jogador := 0; 
   tabuleiro[5][3] := lago;
   tabuleiro[5][4] := lago;
   tabuleiro[6][3] := lago;
   tabuleiro[6][4] := lago;
   tabuleiro[5][7] := lago;
   tabuleiro[5][8] := lago;
   tabuleiro[6][7] := lago;
   tabuleiro[6][8] := lago;
end; { preenche_lago }

{Procedimento para impressão do tabuleiro -> recebe o jogador como parâmetro para ocultar as peças do adversário
 Imprime XX para lago e ## para adversário}
procedure imprime_tabuleiro(jogador : integer);
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
               if (tabuleiro[i][j]^.jogador = jogador) then
                  write(tabuleiro[i][j]^.rank:2, ' ')
               else
                  write('## ');
         writeln;
   end;
end; { imprime_tabuleiro }

{Função para localizar o rank na lista, se ele for válido}
function acha_rank(inicio : no_pecas; rank : integer): no_pecas;
var aux : no_pecas;
begin
   aux := inicio;
   while (aux^.rank <> rank) and (aux <> nil) do
   begin
      aux := aux^.prox;
   end;
   acha_rank := aux;
end;

{Procedimento para dispor as peças de determinado jogador no tabuleiro}
procedure dispor_pecas(jogador : integer; inicio : no_pecas);
var qtde, linha, coluna, rank : integer;
   checagem                   : boolean;
   aux                        : no_pecas;
begin                      
   qtde := 0; {Quantidade de peças dispostas... inicia com 0}
   repeat
      writeln('Digite o rank de uma peça. Use 11 para bomba e 0 para bandeira');
      readln(rank);
      aux := acha_rank(inicio, rank);
      {Se o jogador digitar um rank inválido ele terá que digitar novamente}
      while (aux = nil) or (aux^.qtde >= controle_pecas[rank]) do
      begin
         writeln('Peça indisponível. Por favor, digite novamente o rank');
         readln(rank);
         aux := acha_rank(inicio, rank);
      end;
      checagem := false; {Variável para verificar se o jogador digitou uma posição válida no tabuleiro}
      repeat
         writeln('Digite a posição da peça');
         readln(linha, coluna);
         if (aux^.jogador = 1) then
         begin
            if (linha < 0) or (linha > 4) then
               writeln('Posição inválida')
            else
               checagem := true;
         end
         else
            if (linha > 10) or (linha < 7) then
               writeln('Posição inválida')
            else
               checagem := true;
      until (checagem = true);
      tabuleiro[linha][coluna] := aux;
      inc(aux^.qtde); {Incrementa o número de peças já alocadas na lista do jogador}
      inc(qtde);
      imprime_tabuleiro(jogador);
   until (qtde = 2); {XXX: q = 40}
end; { dispor_pecas }

procedure remove_peca(peca : no_pecas);
begin
   {Decrementa o vetor que diz a quantidade de cada peça}
   dec(peca^.qtde);
end; { remove_peca }

{
Função de combate: ela checa qual peça ganha no combate direto
Valores de retorno:
0 para empate -> exclusão das duas peças
1 para vitória do atacante -> exclusão do atacado
-1 para vitória do atacado -> exclusão do atacante
}
function combate(linha1, coluna1, linha2, coluna2 : integer) : integer;
var atacante, atacado : no_pecas;
begin
   atacante := tabuleiro[linha1][coluna1];
   atacado := tabuleiro[linha2][coluna2];
   {Exceção 1: cabo-armeiro desarma a bomba}
   if (atacante^.rank = 3) and (atacado^.rank = 11) then
   begin
      remove_peca(atacado);
      tabuleiro[linha2][coluna2] := tabuleiro[linha1][coluna1];
      combate := 1;
   end
   else
      {Exceção 2: se o espião atacar o marechal ele ganha}
      if (atacante^.rank = 1) and (atacado^.rank = 10) then
      begin
         remove_peca(atacado);
         tabuleiro[linha2][coluna2] := tabuleiro[linha1][coluna1];
         combate := 1;
      end
      else
         {Regra: ganha quem tiver maior rank}
         if (atacante^.rank > atacado^.rank) then
         begin
            remove_peca(atacado);
            tabuleiro[linha2][coluna2] := tabuleiro[linha1][coluna1];
            combate := 1;
         end
         else
            if (atacante^.rank = atacado^.rank) then
            begin
               remove_peca(atacado);
               remove_peca(atacante);
               tabuleiro[linha2][coluna2] := nil;
               combate:=0;
            end
            else
            begin
               remove_peca(atacante);
               combate:=-1;
            end;
   {O lugar da peça atacante sempre vai ficar vazio -> ou ela toma outro lugar ou ela é derrotada}
   tabuleiro[linha1][coluna1] := nil;
end; { combate }

{Procedimento para exibição de erro}
procedure erros(erro : integer);
begin
   case erro of
     1 : writeln('Espaço vazio. Por favor, tente novamente.');
     2 : writeln('Peça inválida. Por favor, tente novamente.');
     3 : writeln('Peça imóvel. Por favor, tente novamente.');
   end;
end; { erros }

{Funçao verifica se a peça que o jogador escolheu para mover é válida
 recebe um boolean para verificar se imprime ou não o erro}
function valida_espaco(jogador, linha, coluna : integer; exibe : boolean): boolean;
var aux : boolean ;
begin
   aux := false;
   {1. espaço vazio}
   if (tabuleiro[linha][coluna] = nil) then
   begin
      if (exibe) then erros(1)
   end
   else
      {2. verifica se a peça é do próprio jogador}
      if (tabuleiro[linha][coluna]^.jogador <> jogador) then
      begin
         if (exibe) then erros(2)
      end
      else
         {3. verifica se a peça selecionada é móvel}
         if (tabuleiro[linha][coluna]^.rank = 0) or (tabuleiro[linha][coluna]^.rank = 11) then
         begin
            if (exibe) then erros(3);
         end
         else
            aux := true;
   valida_espaco := aux;
end; { valida_espaco }

{Função para ordenar 2 inteiros}
procedure ordena(var int1, int2 : integer);
var
   aux : integer;
begin
   if (int1 > int2) then
   begin
      aux := int1;
      int1 := int2;
      int2 := aux;
   end;
end; { ordena }

{Função verifica se o movimento das peças é válido}
function valida_movimento(linha_atual, coluna_atual, linha, coluna : integer) : boolean;
var aux : boolean;
   rank : integer;
begin   
   aux := false;
   rank := tabuleiro[linha_atual][coluna_atual]^.rank;
   {Está dentro do tabuleiro?}
   if (linha > 0) and (linha <= 10) and (coluna > 0) and (coluna <= 10) then
   begin
      {Regra de movimento: 1 casa horizontal ou vertical}
      if ((linha = linha_atual + 1) and (coluna = coluna_atual)) or ((linha = linha_atual -1) and
         (coluna = coluna_atual)) or ((coluna = coluna_atual + 1) and (linha = linha_atual)) or
         ((coluna = coluna_atual - 1) and (linha = linha_atual)) then
         aux := true;
      {O 2 pode se mover mais de uma casa, mas não pode atacar se fizer isso
       Não pode ter ninguém no caminho do ataque}
      if (rank = 2) then
      begin
         if (linha = linha_atual) then
         begin
            ordena(coluna_atual, coluna);
            aux := true;
            inc(coluna_atual);
            while (coluna <> coluna_atual) do
            begin
               if (tabuleiro[linha][coluna_atual] <> nil) then
                  aux := false;
               inc(coluna_atual);
            end;
         end
         else
            if (coluna = coluna_atual) then
            begin
               ordena(linha_atual, linha);
               aux := true;
               inc(linha_atual);
               while (linha <> linha_atual) do
               begin
                  if (tabuleiro[linha_atual][coluna] <> nil) then
                     aux := false;
                  inc(linha_atual);
               end;
            end;
      end;
   end;
   valida_movimento := aux;
end; { valida_movimento }

{Procedimento para cuidar dos movimentos das peças -> linha_atual e coluna_atual são as coordenadas da peça
 j é o inteiro que representa o jogador 1 ou 2, linha e coluna são as coordenadas que o jogador pretende mover a peça}
function move_peca(jogador, linha_atual, coluna_atual, linha, coluna : integer):boolean;
begin
   {Verifica se é possível o movimento}
   move_peca := valida_movimento(linha_atual, coluna_atual, linha, coluna);
   if (move_peca) then
   begin
      {Se o lugar estiver vazio...}
      if (tabuleiro[linha][coluna] = nil) then
      begin
         tabuleiro[linha][coluna] := tabuleiro[linha_atual][coluna_atual];
         tabuleiro[linha_atual][coluna_atual] := nil;
      end
      else
         combate(linha_atual, coluna_atual, linha, coluna);
   end
   else
      writeln('Movimento inválido. Por favor, tente novamente.');
end;
{ move_peca }

{Função para contar as peças móveis do jogador -> recebe o ponteiro inicial da lista do jogador correspondente}
function conta_pecas (inicio : no_pecas) : integer;
var cont  : integer;
   aux : no_pecas;
begin
   cont := 0;
   aux := inicio;
   while (aux <> nil) do
   begin
      if (aux^.rank > 0) and (aux^.rank <= 10) then
         cont := cont + aux^.qtde;
      aux := aux^.prox;
   end;
   conta_pecas := cont;
end; { conta_pecas }

{Verifica em todo o tabuleiro se as peças do jogador parâmetro podem se mover;
 a qtde se refere ao número de peças móveis restantes}
function pode_mover(jogador : no_pecas; qtde : integer) : boolean;
var
   i, j        : integer;
   nenhum_move : boolean;
   aux         : no_pecas;
begin
   i := 1;
   nenhum_move := true;
   while (nenhum_move) and (qtde > 0) and (i <= 10) do
   begin
      j := 1;
      while (nenhum_move) and (qtde > 0) and (j <= 10) do
      begin
         aux := tabuleiro[i][j];
         { Verifica que existe peça e é do jogador em questão }
         if (aux <> nil) and (valida_espaco(jogador^.jogador, i, j, false)) and (aux^.rank <> 0) then
         begin
            { Verifica se a peça pode se mover em alguma direção. Vale mesmo para o caso do
            soldado. A função valida_movimento já verifica se for passado algum valor fora do tabuleiro}
            if (valida_movimento(i, j, i, j + 1)) or (valida_movimento(i, j, i + 1, j)) or
               (valida_movimento(i, j, i - 1, j)) or (valida_movimento(i, j, i, j - 1)) then
               nenhum_move := false;
            { Decrementa o número de peças do jogador que falta serem verificadas }
            dec(qtde);
         end;
         inc(j);
      end;
      inc(i);
   end;
   
   pode_mover := not nenhum_move;
end; { pode_mover }

{Função verifica se o jogo terminou}
function final_jogo(jogador : integer ): boolean;
var aux   : boolean;
   cont   : integer;
   inicio : no_pecas;
begin
   aux := false;
   cont := 0;
   {1. verificar na lista adversária se existe a bandeira}
   if (jogador = 1) then
      inicio := jog2
   else
      inicio := jog1;
   while (inicio^.rank <> 0) do
      inicio := inicio^.prox;
   if (inicio^.qtde = 0) then
      aux := true;
   {2. checar peças móveis dos dois jogadores}
   cont := conta_pecas(jog1);
   {6 é o número máximo de peças que podem ficar imóveis no jogo, portanto só vale a pena verificar a partir dele}
   if (cont <= 6) then
      if (not pode_mover(jog1, cont)) then
         aux := true;
   cont := conta_pecas(jog2);
   if (cont <= 6) then
      if (not pode_mover(jog2, cont)) then
         aux := true;
   final_jogo := aux;
end; { final_jogo }

var
   final                                                     : boolean;
   rodada, jogador, linha_atual, linha, coluna_atual, coluna : integer;
   
{Programa principal}
begin
   {Preenchimento da área do lago}
   preenche_lago;
   {Aloca memória dos ponteiros dos jogadores}
   new(jog1);
   jog1^.jogador := 1;
   new(jog2);
   jog2^.jogador := 2;
   {Criação de lista para os dois jogadores}
   pecas_jogadores;
   dados_pecas(jog1, 1);
   dados_pecas(jog2, 2);
   {Dispõe peças para os dois jogadores}
   writeln('Vez do jogador 1');
   dispor_pecas(1,jog1); 
   writeln;
   
   clrscr;
   imprime_tabuleiro(2);
   writeln('Vez do jogador 2');
   dispor_pecas(2,jog2);

   jogador := 1;
   clrscr;
   imprime_tabuleiro(jogador);
   rodada := 0;
   
   {Inicio do jogo}
   repeat
      writeln('Vez do jogador ', jogador);
      writeln('Informe as coordenadas da peça que deseja mover');
      readln(linha_atual, coluna_atual);
      {Verifica se o espaço está vazio ou se o a peça escolhida é do jogador}
      if (valida_espaco(jogador, linha_atual,coluna_atual, true)) then 
      begin
         repeat
            writeln('Informe as coordenadas do espaço desejado');
            readln(linha, coluna);
         until (move_peca(jogador, linha_atual, coluna_atual, linha, coluna));
         inc(rodada);
         jogador := (rodada mod 2) + 1;
         final := final_jogo(jogador);
         imprime_tabuleiro(jogador);
         delay(2000);
         clrscr;
      end;
   until (final); {XXX : informar jogador vencedor}
   writeln('It is over, baby');
end.