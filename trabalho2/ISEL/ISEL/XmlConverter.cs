using System;
using System.Collections.Generic;
using System.Linq;
using System.Data.SqlClient;
using System.Xml;
using System.Xml.Linq;
using System.Xml.Schema;

namespace ISEL
{
    public class XmlConverter
    {
        static string getConnectionString()
        {
            return @"Data Source=.;Initial Catalog=ISEL;Integrated Security=True;";
            //return @"Data Source=.;Initial Catalog=ISEL;Integrated Security=True;User ID=User1;Password=user1pwd;";
            // ConfigurationManager.ConnectionStrings["CS"].ConnectionString; ;
        }
        public class LeilaoInfo        {
            public Leilao leilao;
            public string dataInicio;
            public LeilaoInfo(Leilao l, string data)            {
                this.leilao = l;
                dataInicio = data;
            }
        }
        public class LicitInfo {
            public string user;
            public string data;
            public LicitInfo(string user, string data)            {
                this.user = user;
                this.data = data;
            }
        }
        private static List<LeilaoInfo> GetFinishedAuctions()
        {
            List<LeilaoInfo> list = new List<LeilaoInfo>();
            using (SqlConnection con = new SqlConnection())
            {
                con.ConnectionString = getConnectionString();
                using (SqlCommand cmd = con.CreateCommand())
                {
                    cmd.CommandText = "select * from DBO.Leilao L join DBO.Venda V on(V.artigoId = L.artigoId)  WHERE L.artigoId IN (SELECT artigoId FROM DBO.Compra)";
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            Leilao l = new Leilao();
                            l.artigoId = Int32.Parse(dr["artigoId"].ToString());
                            String val = dr["valorMin"].ToString();
                            //Console.WriteLine(val);
                            l.valorMin = Decimal.Parse(val);
                            val = dr["licitacaoMin"].ToString();
                            //Console.WriteLine(val);
                            l.licitacaoMin = Decimal.Parse(val);
                            list.Add(new LeilaoInfo(l, dr["dataInicio"].ToString()));
                        }
                    }
                    con.Close();
                }
            }
            return list;
        }
        private static List<LicitInfo> GetLicitations(int artigoID)        {
            List<LicitInfo> list = new List<LicitInfo>();
            using (SqlConnection con = new SqlConnection())            {
                con.ConnectionString = getConnectionString();
                using (SqlCommand cmd = con.CreateCommand())                {
                    cmd.CommandText = "select * from dbo.Licitacao where artigoId = "+artigoID+" order by dataHora desc";
                    con.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())                    {
                        while (dr.Read())
                            list.Add(new LicitInfo(dr["email"].ToString(), dr["dataHora"].ToString()));
                    }
                    con.Close();
                }
            }
            return list;
        }

        public static void ExportXml()        {
            //LEILOES CONCLUIDOS
            using (var ctx = new ISELEntities2())            {
                Console.WriteLine("Inicio xml");
                // ir buscar os leiloes concluidos
                List<LeilaoInfo> leiloesTerminados = GetFinishedAuctions();

                XmlDocument xdocWriter = new XmlDocument();
                xdocWriter.CreateXmlDeclaration("1.0", "UTF-8", null);     
                XmlElement xmlAuctions = xdocWriter.CreateElement("auctions");
                
                for (int i =0;i< leiloesTerminados.Count; ++i) {
                    Leilao l = leiloesTerminados[i].leilao;
                    XmlElement info = xdocWriter.CreateElement("info");
                    XmlElement minimumBid = xdocWriter.CreateElement("minimumBid");
                    //minimumBid.SetAttribute("minimumBid", l.licitacaoMin.ToString());
                    minimumBid.InnerText = l.licitacaoMin.ToString();
                    //minimumBid.Value=l.licitacaoMin.ToString();
                    XmlElement reservationPrice = xdocWriter.CreateElement("reservationPrice");
                    reservationPrice.InnerText = l.valorMin.ToString();
                    //reservationPrice.Value=(l.valorMin.ToString());
                    XmlElement initialDate = xdocWriter.CreateElement("initialDate");
                    //initialDate.Value=(leiloesTerminados[i].dataInicio);
                    initialDate.InnerText = leiloesTerminados[i].dataInicio;
                    info.AppendChild(minimumBid);
                    info.AppendChild(reservationPrice);
                    info.AppendChild(initialDate);
                    XmlElement bids = xdocWriter.CreateElement("bids");
                    XmlElement bid = null;
                    foreach (LicitInfo licit in GetLicitations(l.artigoId))
                    {
                        bid = xdocWriter.CreateElement("bid");
                        bid.SetAttribute("userid", licit.user);
                        bid.SetAttribute("datetime", licit.data);
                        bids.AppendChild((bid));
                    }
                    XmlElement auction = xdocWriter.CreateElement("auction");
                    auction.SetAttribute("id", "A"+l.artigoId.ToString());
                    auction.AppendChild((info));
                    auction.AppendChild((bids));
                    xmlAuctions.AppendChild(auction);
                }
                
                xdocWriter.AppendChild(xmlAuctions);
                
                xdocWriter.Save("exportedResult.xml");
                Console.WriteLine("Xml finalizado");
                Console.Read();
            }

        }

    }
}
