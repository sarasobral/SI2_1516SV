using System;
using System.Collections.Generic;

using System.Data;
using System.Data.SqlClient;

namespace ISEL {
    class AppADONET
    {
        private SqlConnection con;
        private SqlTransaction tran;
        private enum Option
        {
            Unknown = -1,
            Exit,
            InsertLicitation,
            RemoveLicitation,
            FinishAuction,
            FinishDirectSail,
            LicitationValue,
            LastLicitations,
            Ports,
            UncompletedActions,
            CheckPassword,
            ExportXml
        }
        private static AppADONET __instance;
        private AppADONET()
        {
            __dbMethods = new Dictionary<Option, DBMethod>();
            __dbMethods.Add(Option.InsertLicitation, InsertLicitation);
            __dbMethods.Add(Option.RemoveLicitation, RemoveLicitation);
            __dbMethods.Add(Option.FinishAuction, FinishAuction);
            __dbMethods.Add(Option.FinishDirectSail, FinishDirectSail);
            __dbMethods.Add(Option.LicitationValue, LicitationValue);
            __dbMethods.Add(Option.LastLicitations, LastLicitations);
            __dbMethods.Add(Option.Ports, Ports);
            __dbMethods.Add(Option.UncompletedActions, UncompletedActions);
            __dbMethods.Add(Option.CheckPassword, CheckPassword);
            __dbMethods.Add(Option.ExportXml, XmlConverter.ExportXml);
        }
        public static AppADONET Instance
        {
            get
            {
                if (__instance == null)
                    __instance = new AppADONET();
                return __instance;
            }
            private set { }
        }

        private Option DisplayMenu()
        {
            Option option = Option.Unknown;
            try
            {
                Console.WriteLine("Escolha uma opcao:");
                Console.WriteLine();
                Console.WriteLine("1. Inserir uma licitacao");
                Console.WriteLine("2. Retirar uma licitacao");
                Console.WriteLine("3. Concluir a compra de um leilao");
                Console.WriteLine("4. Realizar a compra de um artigo de venda directa");
                Console.WriteLine("5. Determinar o valor da licitacao de um artigo");
                Console.WriteLine("6. Obter as n ultimas licitacoes");
                Console.WriteLine("7. Obter os portes, dadas duas localizacoes;");
                Console.WriteLine("8. Listar os leiloes que nao foram concluidos;");
                Console.WriteLine("9. Verificar a password de um utilizador"); 
                Console.WriteLine("10. Export xml");
                Console.WriteLine("0. Sair da aplicacao");
                var result = Console.ReadLine();
                option = (Option)Enum.Parse(typeof(Option), result);
            }
            catch (ArgumentException ex)
            {
                //nothing to do. User press select no option and press enter.
            }
            return option;
        }

        public Utils.Credentials getCredentials()
        {
            Console.Write("user: ");
            string username = Console.ReadLine();
            string password = "";
            Console.Write("password: ");

            ConsoleKeyInfo key;
            do
            {
                key = Console.ReadKey(true);
                if (key.Key != ConsoleKey.Backspace && key.Key != ConsoleKey.Enter)
                {
                    password += key.KeyChar;
                    Console.Write("*");
                }
                else
                {
                    if (key.Key == ConsoleKey.Backspace && password.Length > 0)                    {
                        password = password.Substring(0, (password.Length - 1));
                        Console.Write("\b \b");
                    }
                }
            }
            while (key.Key != ConsoleKey.Enter);
            Console.WriteLine();
            return new Utils.Credentials(username, password);
        }

        public Utils.Credentials cr = null;
        private void Login()
        {
            bool check = false;
            Exception ex;
            do
            {
                ex = null;
                cr = getCredentials();
                try
                {
                    con = new SqlConnection();
                    con.ConnectionString = getConnectionString();
                    con.Open();
                }
                catch (Exception e)
                {
                    Console.WriteLine("Introduza novamente os campos");
                    ex = e;
                }
                finally
                {
                    if (con.State == ConnectionState.Open)
                        con.Close();
                    if (ex == null) check = true;
                }
            } while (!check);
        }

        private delegate void DBMethod();
        private System.Collections.Generic.Dictionary<Option, DBMethod> __dbMethods;

        private string getConnectionString()
        {
            return @"Data Source=.;Initial Catalog=ISEL;User Id="+cr.Username+";Password="+cr.Password+";";
        }

        public void Run()
        {
             
                Console.Clear();
                Login();
                Option userInput = Option.Unknown;
                do
                {
                    Console.Clear();
                    userInput = DisplayMenu();
                    Console.Clear();
                    try
                    {
                        __dbMethods[userInput]();
                    }
                    catch (KeyNotFoundException ex)
                    {
                        continue;
                    }
                } while (userInput != Option.Exit);
                    
        }

        //verifica a existencia do utilizador
        private bool CheckUser(string user)
        {
            using (SqlConnection con = new SqlConnection())
            {
                con.ConnectionString = getConnectionString();
                using (SqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "select email from Utilizador";
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                            if (user.Equals(dr["email"].ToString()))
                            {
                                Console.WriteLine("Nome de utilizador correto!");
                                if (con.State == ConnectionState.Open)
                                    con.Close();
                                return true;
                            }
                    }
                    if (con.State == ConnectionState.Open)
                        con.Close();
                }
            }
            Console.WriteLine("Nome de utilizador incorreto!");
            return false;
        }

        //verifica a existencia do artigo
        private bool CheckItem(int artigoId)
        {
            using (SqlConnection con = new SqlConnection())
            {
                con.ConnectionString = getConnectionString();
                using (SqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "select id from Artigo where unCheck=1 and id=" + artigoId;
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                            if (Int32.Parse(dr["id"].ToString()) == artigoId)
                            {
                                if (con.State == ConnectionState.Open)
                                    con.Close();
                                return true;
                            }
                    }
                    if (con.State == ConnectionState.Open)
                        con.Close();
                }
            }
            return false;
        }

        //artigos de leilao
        private List<int> AuctionItem()
        {
            List<int> ids = new List<int>();
            using (SqlConnection con = new SqlConnection())
            {
                con.ConnectionString = getConnectionString();
                using (SqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "select id from dbo.Artigo where unCheck=1 and id in (select artigoId from dbo.Leilao)";
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            ids.Add(Int32.Parse(dr["id"].ToString()));
                        }
                    }
                    if (con.State == ConnectionState.Open)
                        con.Close();
                }
            }
            if (ids.Count > 0)
            {
                Console.Write("Artigos disponiveis em Leilao: ");
                foreach (int id in ids)
                    Console.Write(id + " ");
                Console.WriteLine();
            }
            return ids;
        }

        //artigos de venda direta
        private List<int> DirectSellingItem()
        {
            List<int> ids = new List<int>();
            using (SqlConnection con = new SqlConnection())
            {
                con.ConnectionString = getConnectionString();
                using (SqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "select id from dbo.Artigo where unCheck=1 and id in (select artigoId from dbo.VendaDirecta) and id not in (select artigoId from dbo.Compra)";
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            ids.Add(Int32.Parse(dr["id"].ToString()));
                        }
                    }
                    if (con.State == ConnectionState.Open)
                        con.Close();
                }
            }
            if (ids.Count > 0)
            {
                Console.Write("Artigos disponiveis em Venda Direta: ");
                foreach (int id in ids)
                    Console.Write(id + " ");
                Console.WriteLine();
            }
            return ids;
        }

        //informacao de um artigo
        private void GetInfoItem(int id, string table)
        {
            using (SqlConnection con = new SqlConnection())
            {
                con.ConnectionString = getConnectionString();
                using (SqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "select * from " + table + " where artigoId=" + id + " and artigoId not in (select artigoId from dbo.Compra)";
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        Console.Write("Informacao do artigo: ");
                        if (table.Equals("Leilao"))
                            while (dr.Read())
                                Console.WriteLine("artigoId: " + id + " licitacaoMin: " + dr["licitacaoMin"] + " valorMin: " + dr["valorMin"]);
                        else
                            while (dr.Read())
                                Console.WriteLine("artigoId: " + id + " precoVenda: " + dr["precoVenda"]);
                    }
                    if (con.State == ConnectionState.Open)
                        con.Close();
                }
            }
            Console.WriteLine();
        }

        // verificar se o artigo é válido e apresenta a sua info
        private int AskForItemAndInfo()
        {
            int artigoId = 0;
            bool result = false, artigoValido = false;
            List<int> leilao = AuctionItem();
            List<int> venda = DirectSellingItem();
            if (leilao.Count < 1 && venda.Count < 1)
                return -1;
            while (!artigoValido)
            {
                while (!result)
                {
                    Console.WriteLine("Indique qual o artigo a licitar/verificar:");
                    string art = Console.ReadLine();
                    result = Int32.TryParse(art, out artigoId);
                }
                if (!leilao.Contains(artigoId) && !venda.Contains(artigoId))
                {
                    //nao foi comprado mas ja foi licitado    
                    Console.WriteLine("Artigo indisponível");
                    artigoValido = false;
                    result = false;
                }
                else artigoValido = true;
            }
            GetInfoItem(artigoId, leilao.Contains(artigoId) ? "Leilao" : "VendaDirecta");
            return artigoId;
        }

        // pedir um email
        private string AskForEmail()
        {
            string email = "";
            bool emailValido = false;
            while (!emailValido)
            {
                Console.WriteLine("Indique o seu email:");
                email = Console.ReadLine();
                emailValido = CheckUser(email);
            }
            return email;
        }

        /*---------------------------------------------------------------------------------------------------------*/
        //DONE e get raiserror
        private void InsertLicitation()
        {
            Console.WriteLine("(e) Inserir uma licitação;");
            string user = AskForEmail();
            int artigoId = AskForItemAndInfo();
            if (artigoId == -1)
            {
                Console.WriteLine("Nao existem mais artigos");
                Console.Read();
                return;
            }
            decimal preco = 0;
            bool result = false;
            while (!result)
            {
                Console.WriteLine("Indique o valor que deseja licitar:");
                string p = Console.ReadLine();
                result = Decimal.TryParse(p, out preco);
            }
            string data = Utils.GetDate();
            using (con = new SqlConnection())
            {
                con.ConnectionString = getConnectionString();
                using (SqlCommand cmd = con.CreateCommand())
                {
                    SqlParameter date = new SqlParameter("@data", SqlDbType.Date);
                    SqlParameter prec = new SqlParameter("@preco", SqlDbType.Money);
                    SqlParameter email = new SqlParameter("@email", SqlDbType.VarChar, 50);
                    SqlParameter artigo = new SqlParameter("@artigoId", SqlDbType.Int);
                    cmd.Parameters.AddWithValue("@data", data);
                    cmd.Parameters.AddWithValue("@preco", preco);
                    cmd.Parameters.AddWithValue("@email", user);
                    cmd.Parameters.AddWithValue("@artigoId", artigoId);
                    cmd.CommandText = "dbo.inserirLicitacao";
                    cmd.CommandType = CommandType.StoredProcedure;
                    con.Open();
                    tran = con.BeginTransaction();
                    cmd.Transaction = tran;
                    try
                    {
                        cmd.ExecuteNonQuery();
                        tran.Commit();
                    }
                    catch (SqlException ex)
                    {
                        Console.WriteLine(ex.Message);
                        //tran.Rollback(); nao é necessario pois nao é alterada a BD
                    }
                    finally
                    {
                        if (con.State == ConnectionState.Open)
                            con.Close();
                    }
                }
            }
            //verificar
            VerifyInsertLicitation(data, artigoId, user);
            Console.Read();
        }

        private void VerifyInsertLicitation(string data, int artigoId, string user)
        {
            using (SqlConnection con = new SqlConnection())
            {
                con.ConnectionString = getConnectionString();
                using (SqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "select * from Licitacao where artigoId=" + artigoId + " and dataHora ='" + data + "' and email='" + user + "'";
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                            Console.WriteLine("Licitacao efetuada com sucesso!");
                    }
                }
            }
            if (con.State == ConnectionState.Open)
                con.Close();
        }

        //DONE f get raiserror
        private void RemoveLicitation()
        {
            bool sLicit = false;
            Console.WriteLine("(f) Retirar uma licitação;");
            string user = AskForEmail();
            int artigoId = AskForItemAndInfo();
            if (artigoId == -1)
            {
                Console.WriteLine("Nao existem mais artigos");
                Console.Read();
                return;
            }
            using (SqlConnection con = new SqlConnection())
            {
                con.ConnectionString = getConnectionString();
                using (SqlCommand cmd = con.CreateCommand())
                {
                    SqlParameter email = new SqlParameter("@email", SqlDbType.VarChar, 100);
                    SqlParameter artigo = new SqlParameter("@artigoId", SqlDbType.Int);
                    cmd.Parameters.Add(email);
                    cmd.Parameters.Add(artigo);
                    email.Value = user;
                    artigo.Value = artigoId;
                    cmd.CommandText = "dbo.removerLicitacao";
                    cmd.CommandType = CommandType.StoredProcedure;
                    con.Open();
                    tran = con.BeginTransaction();
                    cmd.Transaction = tran;
                    try
                    {
                        cmd.ExecuteNonQuery();
                        tran.Commit();
                    }
                    catch (SqlException ex)
                    {
                        Console.WriteLine(ex.Message);
                        sLicit = true;
                        //tran.Rollback();
                    }
                    finally
                    {
                        if (con.State == ConnectionState.Open)
                            con.Close();
                    }
                }
            }
            //verificar
            if (!sLicit)
                VerifyRemoveLicitation(artigoId, user);
            Console.Read();
        }

        private void VerifyRemoveLicitation(int artigoId, string user)
        {
            using (SqlConnection con = new SqlConnection())
            {
                con.ConnectionString = getConnectionString();
                using (SqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "select unCheck from Licitacao where dataHora=(select max(dataHora) from Licitacao where artigoId=" + artigoId + " and email='" + user + "')";
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                            Console.WriteLine(dr["unCheck"].ToString().Equals("False") ? "Remocao com sucesso!" : "Erro na remocao!");
                    }
                }
            }
            if (con.State == ConnectionState.Open)
                con.Close();
        }

        //DONE g get raiserror
        private void FinishAuction()
        {
            Console.WriteLine("(g) Concluir a compra de um leilão;");
            List<int> auctions = AuctionItem();
            if (auctions.Count < 1)
            {
                Console.WriteLine("Nao existem artigos em leilao para compra");
                Console.Read();
                return;
            }
            int artigoId = Utils.AskForItem(auctions);
            Console.WriteLine("Insira o local de destino:");
            string local = Console.ReadLine();
            int cartao = Utils.AskForCreditCard();
            using (SqlConnection con = new SqlConnection())
            {
                con.ConnectionString = getConnectionString();
                using (SqlCommand cmd = con.CreateCommand())
                {
                    SqlParameter date = new SqlParameter("@data", SqlDbType.DateTime);
                    SqlParameter locDest = new SqlParameter("@locDest", SqlDbType.VarChar, 2);
                    SqlParameter cc = new SqlParameter("@cc", SqlDbType.Int);
                    SqlParameter artigo = new SqlParameter("@artigoId", SqlDbType.Int);

                    cmd.Parameters.Add(date);
                    cmd.Parameters.Add(locDest);
                    cmd.Parameters.Add(cc);
                    cmd.Parameters.Add(artigo);
                    date.Value = Utils.GetDate();
                    locDest.Value = local;
                    cc.Value = cartao;
                    artigo.Value = artigoId;
                    cmd.CommandText = "dbo.efetuarLeilao";
                    cmd.CommandType = CommandType.StoredProcedure;
                    con.Open();
                    tran = con.BeginTransaction();
                    cmd.Transaction = tran;
                    try
                    {
                        cmd.ExecuteNonQuery();
                        tran.Commit();
                    }
                    catch (SqlException ex)
                    {
                        Console.WriteLine(ex.Message);
                        //tran.Rollback();
                    }
                    finally
                    {
                        if (con.State == ConnectionState.Open)
                            con.Close();
                    }
                }
            }
            VerifyFinishAuction(artigoId);
            Console.Read();
        }

        private void VerifyFinishAuction(int artigoId)
        {
            using (SqlConnection con = new SqlConnection())
            {
                con.ConnectionString = getConnectionString();
                using (SqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "select unCheck from dbo.Artigo where id=" + artigoId;
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                            if (dr["unCheck"].ToString().Equals("False"))
                                Console.WriteLine("Leilao concluido com sucesso!");
                    }
                    
                }
            }
            if (con.State == ConnectionState.Open)
                        con.Close();
        }

        //DONE h get raiserror
        private void FinishDirectSail()
        {
            Console.WriteLine("(h) Realizar a compra de um artigo de venda directa;");
            List<int> sail = DirectSellingItem();
            if (sail.Count < 1)
            {
                Console.WriteLine("Nao existem artigos em venda direta para compra");
                Console.Read();
                return;
            }
            int artigoId = Utils.AskForItem(sail);
            Console.WriteLine("Insira o local de destino:");
            string local = Console.ReadLine();
            int cartao = Utils.AskForCreditCard();
            using (SqlConnection con = new SqlConnection())
            {
                con.ConnectionString = getConnectionString();
                using (SqlCommand cmd = con.CreateCommand())
                {
                    SqlParameter date = new SqlParameter("@data", SqlDbType.DateTime);
                    SqlParameter locDest = new SqlParameter("@locDest", SqlDbType.VarChar, 2);
                    SqlParameter cc = new SqlParameter("@cc", SqlDbType.Int);
                    SqlParameter artigo = new SqlParameter("@artigoId", SqlDbType.Int);

                    cmd.Parameters.Add(date);
                    cmd.Parameters.Add(locDest);
                    cmd.Parameters.Add(cc);
                    cmd.Parameters.Add(artigo);
                    date.Value = Utils.GetDate();
                    locDest.Value = local;
                    cc.Value = cartao;
                    artigo.Value = artigoId;
                    cmd.CommandText = "dbo.efetuarCompraDireta";
                    cmd.CommandType = CommandType.StoredProcedure;
                    con.Open();
                    tran = con.BeginTransaction();
                    cmd.Transaction = tran;
                    try
                    {
                        cmd.ExecuteNonQuery();
                        tran.Commit();
                    }
                    catch (SqlException ex)
                    {
                        Console.WriteLine(ex.Message);
                        //tran.Rollback();
                    }
                    finally
                    {
                        if (con.State == ConnectionState.Open)
                            con.Close();
                    }
                }
            }
            VerifyFinishDirectSail(artigoId);
            Console.Read();
        }

        private void VerifyFinishDirectSail(int artigoId)
        {
            using (SqlConnection con = new SqlConnection())
            {
                con.ConnectionString = getConnectionString();
                using (SqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "select unCheck from dbo.Artigo where id=" + artigoId;
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                            if (dr["unCheck"].ToString().Equals("False"))
                                Console.WriteLine("Venda direta concluida com sucesso!");
                    }
                }
            }
            if (con.State == ConnectionState.Open)
                con.Close();
        }

        //DONE i
        private void LicitationValue()
        {
            Console.WriteLine("(i) Determinar o valor da licitação de um artigo;");
            int artigoId = AskForItemAndInfo();
            if (artigoId == -1)
            {
                Console.WriteLine("Nao existem mais artigos");
                Console.Read();
                return;
            }
            using (SqlConnection con = new SqlConnection())
            {
                con.ConnectionString = getConnectionString();
                using (SqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "select * from dbo.valorLicit(" + artigoId + ")";
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        int count = 0;
                        while (dr.Read())
                        {
                            ++count;
                            Console.WriteLine("artigo: " + dr["artigoId"] + ", email: " + dr["email"] + ", data/hora: " + dr["dataHora"] + ", preco: " + dr["preco"] + " euro(s)");
                        }
                        if (count == 0)
                            Console.WriteLine("Nao existem licitacoes para esse artigo");
                    }
                    if (con.State == ConnectionState.Open)
                        con.Close();
                }
            }
            Console.Read();
        }

        //DONE j
        private void LastLicitations()
        {
            Console.WriteLine("(j) Obter as n últimas licitações;");
            int n = 0;
            bool result = false;
            while (!result && n < 1)
            {
                Console.WriteLine("Indique quantas licitacoes pretende ver:");
                string p = Console.ReadLine();
                result = Int32.TryParse(p, out n);
            }
            using (SqlConnection con = new SqlConnection())
            {
                con.ConnectionString = getConnectionString();
                using (SqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "select * from dbo.nLicitacao(" + n + ");";
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        int count = 0;
                        while (dr.Read())
                        {
                            ++count;
                            Console.WriteLine("artigo " + dr["artigoId"] + ", email: " + dr["email"] + ", data/hora: " + dr["dataHora"] + ", preco: " + dr["preco"] + " euro(s)");
                        }
                        if (count == 0)
                            Console.WriteLine("Nao existem licitacoes");
                    }
                    if (con.State == ConnectionState.Open)
                        con.Close();
                }
            }
            Console.Read();
        }

        //DONE k
        private void Ports()
        {
            Console.WriteLine("(k) Obter os portes, dadas duas localizações;");
            string orig, dest, val = null;
            Console.WriteLine("Indique o local de origem:");
            orig = Console.ReadLine();
            Console.WriteLine("Indique o local de destino:");
            dest = Console.ReadLine();
            using (SqlConnection con = new SqlConnection())
            {
                con.ConnectionString = getConnectionString();
                using (SqlCommand cmd = con.CreateCommand())
                {
                    SqlParameter or = new SqlParameter("@locOrigem", SqlDbType.VarChar, 2);
                    SqlParameter de = new SqlParameter("@locDestino", SqlDbType.VarChar, 2);
                    SqlParameter valor = new SqlParameter("@valorPorte", SqlDbType.Int);
                    valor.Direction = ParameterDirection.Output;
                    cmd.Parameters.Add(or);
                    cmd.Parameters.Add(de);
                    cmd.Parameters.Add(valor);
                    or.Value = orig;
                    de.Value = dest;
                    cmd.CommandText = "dbo.valuePorte";
                    cmd.CommandType = CommandType.StoredProcedure;
                    con.Open();
                    try
                    {
                        cmd.ExecuteReader();
                        val = valor.Value.ToString();
                        if (val != "")
                            Console.WriteLine("Valor do porte entre " + orig + " e " + dest + " é de " + val + " euro(s)");
                        else
                            Console.WriteLine("Locais inválidos");
                    }
                    catch (SqlException ex)
                    {
                        Console.WriteLine(ex.Message);
                        //tran.Rollback();
                    }
                    finally
                    {
                        if (con.State == ConnectionState.Open)
                            con.Close();
                    }
                }
            }
            Console.Read();
        }

        //DONE l
        private void UncompletedActions()
        {
            Console.WriteLine("(l) Listar os leilies nao concluídos;");
            using (SqlConnection con = new SqlConnection())
            {
                con.ConnectionString = getConnectionString();
                using (SqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "select * from dbo.leilaoNaoConcluido";
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                            Console.WriteLine("Licitacao com o id " + Int32.Parse(dr["lid"].ToString()));
                    }
                    if (con.State == ConnectionState.Open)
                        con.Close();
                }
            }
            using (SqlConnection con = new SqlConnection())
            {
                con.ConnectionString = getConnectionString();
                using (SqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "select * from dbo.Venda where artigoId in (select artigoId from leilao where unCheck=1)";
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                            Console.WriteLine("artigoId: " + dr["artigoId"] + ", email: " + dr["email"] +
                                ", data de inicio: " + dr["dataInicio"] + ", data de fim: " + dr["dataFim"] +
                                ", local de origem: " + dr["localOrigem"] + ", condicao: " + dr["condicao"] + ", descricao: " + dr["descricao"]);
                    }
                    if (con.State == ConnectionState.Open)
                        con.Close();
                }
            }
            Console.Read();
        }
        // done M
        private void CheckPassword()
        {
            Console.WriteLine("(m) Verificar a password de um utilizador; ");
            Utils.Credentials cred = getCredentials();
            using (SqlConnection con = new SqlConnection())
            {
                con.ConnectionString = getConnectionString();
                using (SqlCommand cmd = con.CreateCommand())
                {
                    SqlParameter email = new SqlParameter("@email", SqlDbType.VarChar, 100);
                    SqlParameter pp = new SqlParameter("@pp", SqlDbType.VarChar, 50);
                    SqlParameter retval = new SqlParameter("@return", SqlDbType.Int);
                    
                    cmd.Parameters.Add(email);
                    cmd.Parameters.Add(pp);
                    cmd.Parameters.Add(retval);
                    email.Value = cred.Username;
                    pp.Value = cred.Password;

                    retval.Direction = ParameterDirection.ReturnValue;

                    cmd.CommandText = "dbo.verificarPp";
                    cmd.CommandType = CommandType.StoredProcedure;
                    con.Open();
                    try
                    {
                        cmd.ExecuteReader();
                        string val = retval.Value.ToString();
                        if (val.Equals("0"))
                        {
                            Console.WriteLine("Palavra passe correta!");
                            Console.Read();
                            return;
                        }
                        else Console.WriteLine("Palavra passe incorreta!");
                    }
                    catch (SqlException ex)
                    {
                        Console.WriteLine(ex.Message);
                    }
                    finally
                    {
                        if (con.State == ConnectionState.Open)
                            con.Close();
                    }
                }
            }
            Console.Read();
        }
    }

    class MainClass {
        public static void Main(string[] args) {
            int choose = 0;
            do
            {
                Console.WriteLine("Quer correr a aplicaçao em:");
                Console.WriteLine("1. ADO.NET");
                Console.WriteLine("2. Entity FrameWork");
                string key = Console.ReadLine();
                Int32.TryParse(key, out choose);
            } while (choose != 1 && choose != 2);
            if (choose == 2)
                AppEF.Ef();
            else
                AppADONET.Instance.Run();
        }
    }
}
