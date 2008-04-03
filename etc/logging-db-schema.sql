-- MySQL dump 10.10
--
-- Host: localhost    Database: logging
-- ------------------------------------------------------
-- Server version	5.0.27

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `callback_log`
--

DROP TABLE IF EXISTS `callback_log`;
CREATE TABLE `callback_log` (
  `id` int(11) NOT NULL auto_increment,
  `site` varchar(255) NOT NULL,
  `rule` varchar(100) default NULL,
  `caller` varchar(255) default NULL,
  `user_id` varchar(100) default NULL,
  `sense` varchar(255) default NULL,
  `date` datetime NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `callback_log`
--

LOCK TABLES `callback_log` WRITE;
/*!40000 ALTER TABLE `callback_log` DISABLE KEYS */;
INSERT INTO `callback_log` VALUES (1,'10','accept_offer','http://www.windley.com/identity-policy/','a41c7ccf295829e62f7045b3713ff033','success','0000-00-00 00:00:00'),(2,'10','accept_offer','http://www.windley.com/identity-policy/','a41c7ccf295829e62f7045b3713ff033','success','0000-00-00 00:00:00'),(3,'10','accept_offer','http://www.windley.com/identity-policy/','a41c7ccf295829e62f7045b3713ff033','success','0000-00-00 00:00:00'),(4,'10','accept_offer','http://www.windley.com/identity-policy/','a41c7ccf295829e62f7045b3713ff033','success','0000-00-00 00:00:00'),(5,'10','accept_offer','http://www.windley.com/identity-policy/','a41c7ccf295829e62f7045b3713ff033','success','0000-00-00 00:00:00'),(6,'10','accept_offer','http://www.windley.com/identity-policy/','a41c7ccf295829e62f7045b3713ff033','success','2008-03-22 15:27:28'),(7,'10','accept_offer','http://www.windley.com/identity-policy/','a41c7ccf295829e62f7045b3713ff033','success','2008-03-22 15:32:34'),(8,'10','accept_offer','http://www.windley.com/identity-policy/','a41c7ccf295829e62f7045b3713ff033','success','2008-03-22 15:55:09'),(9,'10','accept_offer','http://www.windley.com/identity-policy/','a41c7ccf295829e62f7045b3713ff033','success','2008-03-22 16:04:07');
/*!40000 ALTER TABLE `callback_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rule_log`
--

DROP TABLE IF EXISTS `rule_log`;
CREATE TABLE `rule_log` (
  `id` int(11) NOT NULL auto_increment,
  `timestamp` datetime NOT NULL,
  `site` varchar(255) NOT NULL,
  `rule` varchar(100) default NULL,
  `caller` varchar(255) default NULL,
  `user_id` varchar(100) default NULL,
  `user_ip` varchar(15) default NULL,
  `referer` varchar(255) default NULL,
  `title` varchar(254) default NULL,
  `action` varchar(30) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `rule_log`
--

LOCK TABLES `rule_log` WRITE;
/*!40000 ALTER TABLE `rule_log` DISABLE KEYS */;
INSERT INTO `rule_log` VALUES (1,'2008-03-22 17:00:22','10','accept_offer','http://www.windley.com/identity-policy/','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','','Phil Windley\'s Technometria | Identity Policy Templates','replace'),(2,'2008-03-22 17:04:16','10','daytime','http://www.windley.com/archives/2008/03/','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.windley.com/identity-policy/','Phil Windley\'s Technometria | March 2008 Archives','float'),(3,'2008-03-22 17:05:46','10','google_ads','http://www.windley.com/archives/2005/06/free_mobile_cal.shtml','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.google.com/search?q','Phil Windley\'s Technometria | Free Mobile Calls to Anywhere in the World','replace'),(4,'2008-03-22 17:05:46','10','daytime','http://www.windley.com/archives/2005/06/free_mobile_cal.shtml','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.google.com/search?q','Phil Windley\'s Technometria | Free Mobile Calls to Anywhere in the World','float'),(5,'2008-03-22 17:16:34','10','daytime','http://www.windley.com/archives/2008/03/visualizing_workflow_and_transparent_systems.shtml','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.windley.com/','Phil Windley\'s Technometria | Visualizing Workflow and Transparent Systems','float'),(6,'2008-03-22 17:18:26','10','accept_offer','http://www.windley.com/identity-policy/','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.windley.com/cto_forum','Phil Windley\'s Technometria | Identity Policy Templates','replace'),(7,'2008-03-22 17:21:53','10','market_up_test','http://www.windley.com/essays/2004/how_to_start_a_blog','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.windley.com/essays/2004/','Phil Windley\'s Technometria | How to Start a Blog','alert'),(8,'2008-03-22 17:21:53','10','market_down_test','http://www.windley.com/essays/2004/how_to_start_a_blog','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.windley.com/essays/2004/','Phil Windley\'s Technometria | How to Start a Blog','not_fired'),(9,'2008-03-26 15:16:26','10001','Need Foo','http://phil.windley.org/','ed390d6fb5840c1411b314762672deaf','72.21.203.1','http://www.windley.com/essays/2004/how_to_start_a_blog','Phillip J. Windley | Short Biography','float'),(10,'2008-03-26 15:21:11','10001','Need Foo','http://phil.windley.org/','ed390d6fb5840c1411b314762672deaf','72.21.203.1','http://www.windley.com/essays/2004/how_to_start_a_blog','Phillip J. Windley | Short Biography','float'),(11,'2008-03-26 15:29:21','10001','Need Foo','http://phil.windley.org/','ed390d6fb5840c1411b314762672deaf','72.21.203.1','http://www.windley.com/essays/2004/how_to_start_a_blog','Phillip J. Windley | Short Biography','float'),(12,'2008-03-26 15:31:42','10001','Need Foo','http://phil.windley.org/','ed390d6fb5840c1411b314762672deaf','72.21.203.1','http://www.windley.com/essays/2004/how_to_start_a_blog','Phillip J. Windley | Short Biography','float'),(13,'2008-03-26 15:34:01','10001','Need Foo','http://phil.windley.org/','ed390d6fb5840c1411b314762672deaf','72.21.203.1','http://www.windley.com/essays/2004/how_to_start_a_blog','Phillip J. Windley | Short Biography','float'),(14,'2008-03-26 15:35:44','10001','Need Foo','http://phil.windley.org/','ed390d6fb5840c1411b314762672deaf','72.21.203.1','http://www.windley.com/essays/2004/how_to_start_a_blog','Phillip J. Windley | Short Biography','float'),(15,'2008-03-28 16:16:20','10','google_ads','http://www.windley.com/archives/2008/03/','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.windley.com/','Phil Windley\'s Technometria | March 2008 Archives','not_fired'),(16,'2008-03-28 16:16:22','10','daytime','http://www.windley.com/archives/2008/03/','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.windley.com/','Phil Windley\'s Technometria | March 2008 Archives','float'),(17,'2008-03-28 16:16:22','10','frequent_archive_visitor','http://www.windley.com/archives/2008/03/','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.windley.com/','Phil Windley\'s Technometria | March 2008 Archives','not_fired'),(18,'2008-03-28 16:18:30','10','google_ads','http://www.windley.com/archives/2008/03/','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.windley.com/','Phil Windley\'s Technometria | March 2008 Archives','not_fired'),(19,'2008-03-28 16:18:32','10','daytime','http://www.windley.com/archives/2008/03/','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.windley.com/','Phil Windley\'s Technometria | March 2008 Archives','float'),(20,'2008-03-28 16:18:32','10','frequent_archive_visitor','http://www.windley.com/archives/2008/03/','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.windley.com/','Phil Windley\'s Technometria | March 2008 Archives','not_fired'),(21,'2008-03-28 16:20:52','10','google_ads','http://www.windley.com/archives/2008/03/','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.windley.com/','Phil Windley\'s Technometria | March 2008 Archives','not_fired'),(22,'2008-03-28 16:20:53','10','daytime','http://www.windley.com/archives/2008/03/','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.windley.com/','Phil Windley\'s Technometria | March 2008 Archives','float'),(23,'2008-03-28 16:20:53','10','frequent_archive_visitor','http://www.windley.com/archives/2008/03/','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.windley.com/','Phil Windley\'s Technometria | March 2008 Archives','not_fired'),(24,'2008-04-01 15:32:18','10','google_ads','http://www.windley.com/archives/2008/03/','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.windley.com/','Phil Windley\'s Technometria | March 2008 Archives','not_fired'),(25,'2008-04-01 15:32:19','10','daytime','http://www.windley.com/archives/2008/03/','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.windley.com/','Phil Windley\'s Technometria | March 2008 Archives','float'),(26,'2008-04-01 15:32:19','10','frequent_archive_visitor','http://www.windley.com/archives/2008/03/','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.windley.com/','Phil Windley\'s Technometria | March 2008 Archives','not_fired'),(27,'2008-04-01 15:35:08','10','google_ads','http://www.windley.com/archives/2008/03/','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.windley.com/','Phil Windley\'s Technometria | March 2008 Archives','not_fired'),(28,'2008-04-01 15:35:08','10','daytime','http://www.windley.com/archives/2008/03/','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.windley.com/','Phil Windley\'s Technometria | March 2008 Archives','float'),(29,'2008-04-01 15:35:08','10','frequent_archive_visitor','http://www.windley.com/archives/2008/03/','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.windley.com/','Phil Windley\'s Technometria | March 2008 Archives','not_fired'),(30,'2008-04-01 15:35:42','10','google_ads','http://www.windley.com/archives/2008/03/','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.windley.com/','Phil Windley\'s Technometria | March 2008 Archives','not_fired'),(31,'2008-04-01 15:35:44','10','daytime','http://www.windley.com/archives/2008/03/','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.windley.com/','Phil Windley\'s Technometria | March 2008 Archives','float'),(32,'2008-04-01 15:35:44','10','frequent_archive_visitor','http://www.windley.com/archives/2008/03/','e8459f24477c1a39d7aefb17a3ca27e5','72.21.203.1','http://www.windley.com/','Phil Windley\'s Technometria | March 2008 Archives','not_fired'),(33,'2008-04-03 10:22:05','10','google_ads','http://www.windley.com/archives/2008/04/top_ten_it_conversations_shows_for_march_2008.shtml','32f3315bc7b83d56a3026a2292e88b74','72.21.203.1','http://www.windley.com/','Phil Windley\'s Technometria | Top Ten IT Conversations Shows for March 2008','not_fired'),(34,'2008-04-03 10:22:07','10','daytime','http://www.windley.com/archives/2008/04/top_ten_it_conversations_shows_for_march_2008.shtml','32f3315bc7b83d56a3026a2292e88b74','72.21.203.1','http://www.windley.com/','Phil Windley\'s Technometria | Top Ten IT Conversations Shows for March 2008','float'),(35,'2008-04-03 10:22:07','10','frequent_archive_visitor','http://www.windley.com/archives/2008/04/top_ten_it_conversations_shows_for_march_2008.shtml','32f3315bc7b83d56a3026a2292e88b74','72.21.203.1','http://www.windley.com/','Phil Windley\'s Technometria | Top Ten IT Conversations Shows for March 2008','not_fired');
/*!40000 ALTER TABLE `rule_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_info`
--

DROP TABLE IF EXISTS `schema_info`;
CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `schema_info`
--

LOCK TABLES `schema_info` WRITE;
/*!40000 ALTER TABLE `schema_info` DISABLE KEYS */;
INSERT INTO `schema_info` VALUES (3);
/*!40000 ALTER TABLE `schema_info` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2008-04-03 19:05:55
