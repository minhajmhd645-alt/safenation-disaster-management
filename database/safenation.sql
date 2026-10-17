-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: safenation_disaster_link
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `safenation_disaster_link`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `safenation_disaster_link` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;

USE `safenation_disaster_link`;

--
-- Table structure for table `alerts`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `alerts` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `author_id` int(10) unsigned NOT NULL,
  `type_id` int(10) unsigned NOT NULL,
  `title` varchar(150) NOT NULL,
  `message` text NOT NULL,
  `area` varchar(100) NOT NULL,
  `severity` varchar(16) NOT NULL,
  `published_at` datetime NOT NULL DEFAULT current_timestamp(),
  `expires_at` datetime DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `author_id` (`author_id`),
  KEY `type_id` (`type_id`),
  KEY `active` (`active`,`expires_at`),
  CONSTRAINT `alerts_ibfk_1` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`),
  CONSTRAINT `alerts_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `disaster_types` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alerts`
--

LOCK TABLES `alerts` WRITE;
/*!40000 ALTER TABLE `alerts` DISABLE KEYS */;
INSERT INTO `alerts` VALUES (1,2,1,'Example alert: flood response update','Example alert for project testing. A flood response is being coordinated in this scenario. View the situation map and example facilities for details.','Kandy','High','2026-10-01 10:31:55','2026-10-08 10:31:55',1);
/*!40000 ALTER TABLE `alerts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `archive_safenation_alerts`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_safenation_alerts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `disaster_type_id` int(11) DEFAULT NULL,
  `severity` enum('Information','Warning','Emergency','Critical') NOT NULL,
  `location_name` varchar(255) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `radius_km` int(11) DEFAULT NULL,
  `start_time` datetime NOT NULL,
  `expiry_time` datetime DEFAULT NULL,
  `recommended_action` text DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `disaster_type_id` (`disaster_type_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `archive_safenation_alerts_ibfk_1` FOREIGN KEY (`disaster_type_id`) REFERENCES `archive_safenation_disaster_types` (`id`),
  CONSTRAINT `archive_safenation_alerts_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `archive_safenation_users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archive_safenation_alerts`
--

LOCK TABLES `archive_safenation_alerts` WRITE;
/*!40000 ALTER TABLE `archive_safenation_alerts` DISABLE KEYS */;
INSERT INTO `archive_safenation_alerts` VALUES (1,'Major Flood Warning for Kelani River Basin','The water level of the Kelani river is rising rapidly. Residents in low-lying areas of Kelaniya, Kolonnawa, and Biyagama are advised to evacuate immediately to higher ground or designated safe shelters.',1,'Critical','Kelani River Basin',6.94500000,79.91000000,10,'2026-09-09 20:00:29','2026-09-11 21:00:29','Evacuate immediately. Follow instructions from local authorities.',2,'2026-09-09 15:30:29'),(2,'High Wind Warning','Gusty winds up to 70kmph expected in Western Province. Coastal communities should remain vigilant.',4,'Warning','Western Province',6.92710000,79.86120000,50,'2026-09-09 15:00:29','2026-09-10 09:00:29','Secure loose objects. Avoid fishing in the sea.',2,'2026-09-09 15:30:29');
/*!40000 ALTER TABLE `archive_safenation_alerts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `archive_safenation_assistance_requests`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_safenation_assistance_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `request_type` enum('Medical assistance','Food','Water','Evacuation','Shelter','Rescue','Vulnerable-person assistance','Other') NOT NULL,
  `description` text NOT NULL,
  `location_name` varchar(255) NOT NULL,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  `priority` enum('LOW','MEDIUM','HIGH','CRITICAL') NOT NULL,
  `number_of_people` int(11) DEFAULT 1,
  `contact` varchar(100) NOT NULL,
  `status` enum('Pending','Assigned','In Progress','Completed','Cancelled') DEFAULT 'Pending',
  `assigned_to` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `assigned_to` (`assigned_to`),
  CONSTRAINT `archive_safenation_assist_req_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `archive_safenation_users` (`id`),
  CONSTRAINT `archive_safenation_assist_req_ibfk_2` FOREIGN KEY (`assigned_to`) REFERENCES `archive_safenation_users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archive_safenation_assistance_requests`
--

LOCK TABLES `archive_safenation_assistance_requests` WRITE;
/*!40000 ALTER TABLE `archive_safenation_assistance_requests` DISABLE KEYS */;
INSERT INTO `archive_safenation_assistance_requests` VALUES (1,3,'Evacuation','Trapped on the second floor. Water is entering the ground floor. Need boat rescue.','No 45, Riverside road, Kelanimulla',6.94150000,79.91700000,'CRITICAL',4,'+94770000003','Assigned',5,'2026-09-09 15:30:29','2026-09-09 15:30:29'),(2,3,'Medical assistance','Elderly person needs insulin. We cannot leave the house due to flooded roads.','No 15, Galle Road, Rathmalana',6.82000000,79.87000000,'HIGH',1,'+94770000003','Pending',NULL,'2026-09-09 15:30:29','2026-09-09 15:30:29');
/*!40000 ALTER TABLE `archive_safenation_assistance_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `archive_safenation_audit_logs`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_safenation_audit_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `action` varchar(255) NOT NULL,
  `module` varchar(100) NOT NULL,
  `record_id` varchar(50) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `archive_safenation_audit_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `archive_safenation_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archive_safenation_audit_logs`
--

LOCK TABLES `archive_safenation_audit_logs` WRITE;
/*!40000 ALTER TABLE `archive_safenation_audit_logs` DISABLE KEYS */;
INSERT INTO `archive_safenation_audit_logs` VALUES (1,7,'Register','Auth','7','::1','2026-09-09 16:00:51'),(2,7,'Login','Auth','7','::1','2026-09-09 16:01:14'),(3,7,'Logout','Auth','7','::1','2026-09-09 16:03:33'),(4,7,'Login','Auth','7','::1','2026-09-09 16:04:35'),(5,7,'Submit Report','Disaster Reporting','4','::1','2026-09-09 16:06:10'),(6,7,'Logout','Auth','7','::1','2026-09-09 16:07:40');
/*!40000 ALTER TABLE `archive_safenation_audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `archive_safenation_disaster_report_images`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_safenation_disaster_report_images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `report_id` int(11) NOT NULL,
  `image_path` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `report_id` (`report_id`),
  CONSTRAINT `archive_safenation_images_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `archive_safenation_disaster_reports` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archive_safenation_disaster_report_images`
--

LOCK TABLES `archive_safenation_disaster_report_images` WRITE;
/*!40000 ALTER TABLE `archive_safenation_disaster_report_images` DISABLE KEYS */;
/*!40000 ALTER TABLE `archive_safenation_disaster_report_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `archive_safenation_disaster_reports`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_safenation_disaster_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `incident_id` varchar(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `type_id` int(11) NOT NULL,
  `description` text NOT NULL,
  `location_name` varchar(255) NOT NULL,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  `reported_at` datetime NOT NULL,
  `severity_estimated` enum('LOW','MEDIUM','HIGH','CRITICAL') NOT NULL,
  `severity_ai` enum('LOW','MEDIUM','HIGH','CRITICAL') DEFAULT NULL,
  `severity_confirmed` enum('LOW','MEDIUM','HIGH','CRITICAL') DEFAULT NULL,
  `affected_people` int(11) DEFAULT 0,
  `infrastructure_damage` text DEFAULT NULL,
  `status` enum('Submitted','Under Review','Verified','Response in Progress','Resolved','Rejected','Duplicate','Requires Further Investigation') DEFAULT 'Submitted',
  `verified_by` int(11) DEFAULT NULL,
  `response_team_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `incident_id` (`incident_id`),
  KEY `user_id` (`user_id`),
  KEY `type_id` (`type_id`),
  KEY `verified_by` (`verified_by`),
  KEY `response_team_id` (`response_team_id`),
  CONSTRAINT `archive_safenation_reports_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `archive_safenation_users` (`id`),
  CONSTRAINT `archive_safenation_reports_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `archive_safenation_disaster_types` (`id`),
  CONSTRAINT `archive_safenation_reports_ibfk_3` FOREIGN KEY (`verified_by`) REFERENCES `archive_safenation_users` (`id`),
  CONSTRAINT `archive_safenation_reports_ibfk_4` FOREIGN KEY (`response_team_id`) REFERENCES `archive_safenation_response_teams` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archive_safenation_disaster_reports`
--

LOCK TABLES `archive_safenation_disaster_reports` WRITE;
/*!40000 ALTER TABLE `archive_safenation_disaster_reports` DISABLE KEYS */;
INSERT INTO `archive_safenation_disaster_reports` VALUES (1,'SN-2026-000001',3,1,'Severe flooding in Kelani River banks. Water level is rising rapidly. Several houses are underwater.','Kelanimulla',6.94120000,79.91680000,'2026-09-09 19:00:29','HIGH','HIGH','HIGH',150,'Multiple houses flooded. Power lines down.','Response in Progress',2,2,'2026-09-09 15:30:29','2026-09-09 15:30:29'),(2,'SN-2026-000002',3,4,'Strong winds have blown off roofs in the area. A massive tree has fallen across the main road.','Wellawatte',6.87410000,79.86010000,'2026-09-09 16:00:29','MEDIUM','MEDIUM','MEDIUM',10,'Road blocked. Power lines damaged.','Verified',2,NULL,'2026-09-09 15:30:29','2026-09-09 15:30:29'),(3,'SN-2026-000003',4,3,'Factory fire. Large plumes of black smoke. Seems to be spreading to nearby warehouses.','Orugodawatta',6.93600000,79.88200000,'2026-09-09 20:30:29','CRITICAL','CRITICAL','CRITICAL',50,'Factory building severely damaged. High risk of explosion.','Response in Progress',2,1,'2026-09-09 15:30:29','2026-09-09 15:30:29'),(4,'SN-2026-000004',7,1,'very difficult to find shelters','near ragala hindu temple',6.88810500,80.92537500,'2026-09-09 21:36:10','HIGH',NULL,NULL,100,'road blocked','Submitted',NULL,NULL,'2026-09-09 16:06:10','2026-09-09 16:06:10');
/*!40000 ALTER TABLE `archive_safenation_disaster_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `archive_safenation_disaster_types`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_safenation_disaster_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archive_safenation_disaster_types`
--

LOCK TABLES `archive_safenation_disaster_types` WRITE;
/*!40000 ALTER TABLE `archive_safenation_disaster_types` DISABLE KEYS */;
INSERT INTO `archive_safenation_disaster_types` VALUES (1,'Flood','Rising water levels in rivers or low-lying areas'),(2,'Landslide','Movement of rock, earth, or debris down a sloped section of land'),(3,'Fire','Uncontrolled fire in urban or rural settings'),(4,'Storm','Severe weather condition, cyclone, or high winds'),(5,'Heavy Rainfall','Extreme precipitation leading to localized issues'),(6,'Road Emergency','Major accidents or road collapse'),(7,'Building Emergency','Building collapse or structural failure'),(8,'Other','Other emergencies not classified');
/*!40000 ALTER TABLE `archive_safenation_disaster_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `archive_safenation_hospital_facilities`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_safenation_hospital_facilities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hospital_id` int(11) NOT NULL,
  `facility_name` varchar(100) NOT NULL,
  `is_available` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `hospital_id` (`hospital_id`),
  CONSTRAINT `archive_safenation_hosp_fac_ibfk_1` FOREIGN KEY (`hospital_id`) REFERENCES `archive_safenation_hospitals` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archive_safenation_hospital_facilities`
--

LOCK TABLES `archive_safenation_hospital_facilities` WRITE;
/*!40000 ALTER TABLE `archive_safenation_hospital_facilities` DISABLE KEYS */;
/*!40000 ALTER TABLE `archive_safenation_hospital_facilities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `archive_safenation_hospitals`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_safenation_hospitals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `address` text NOT NULL,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  `contact` varchar(100) NOT NULL,
  `emergency_department` tinyint(1) DEFAULT 1,
  `operating_status` enum('Available','Limited Capacity','Full','Closed') DEFAULT 'Available',
  `notes` text DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `updated_by` (`updated_by`),
  CONSTRAINT `archive_safenation_hospitals_ibfk_1` FOREIGN KEY (`updated_by`) REFERENCES `archive_safenation_users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archive_safenation_hospitals`
--

LOCK TABLES `archive_safenation_hospitals` WRITE;
/*!40000 ALTER TABLE `archive_safenation_hospitals` DISABLE KEYS */;
INSERT INTO `archive_safenation_hospitals` VALUES (1,'National Hospital of Sri Lanka','Regent Street, Colombo 10',6.91890000,79.86870000,'+94112691111',1,'Available','Fully operational. Blood bank urgently needs O+',6,'2026-09-09 15:30:29','2026-09-09 15:30:29'),(2,'Colombo South Teaching Hospital (Kalubowila)','Hospital Road, Dehiwala-Mount Lavinia',6.86600000,79.87320000,'+94112815151',1,'Limited Capacity','Emergency ward is running near capacity due to recent floods.',2,'2026-09-09 15:30:29','2026-09-09 15:30:29'),(3,'Lady Ridgeway Hospital for Children','Dr. Danister De Silva Mawatha, Colombo 08',6.92000000,79.87530000,'+94112693711',1,'Available','Pediatric emergencies only.',2,'2026-09-09 15:30:29','2026-09-09 15:30:29');
/*!40000 ALTER TABLE `archive_safenation_hospitals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `archive_safenation_incident_history`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_safenation_incident_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `incident_id` varchar(20) NOT NULL,
  `status` varchar(50) NOT NULL,
  `changed_by` int(11) NOT NULL,
  `notes` text DEFAULT NULL,
  `changed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `incident_id` (`incident_id`),
  KEY `changed_by` (`changed_by`),
  CONSTRAINT `archive_safenation_history_ibfk_1` FOREIGN KEY (`incident_id`) REFERENCES `archive_safenation_disaster_reports` (`incident_id`) ON DELETE CASCADE,
  CONSTRAINT `archive_safenation_history_ibfk_2` FOREIGN KEY (`changed_by`) REFERENCES `archive_safenation_users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archive_safenation_incident_history`
--

LOCK TABLES `archive_safenation_incident_history` WRITE;
/*!40000 ALTER TABLE `archive_safenation_incident_history` DISABLE KEYS */;
INSERT INTO `archive_safenation_incident_history` VALUES (1,'SN-2026-000001','Submitted',3,'Initial report submitted by citizen.','2026-09-09 15:30:29'),(2,'SN-2026-000001','Under Review',2,'Authority is reviewing the drone footage of the area.','2026-09-09 15:30:29'),(3,'SN-2026-000001','Verified',2,'Flood confirmed via satellite imagery.','2026-09-09 15:30:29'),(4,'SN-2026-000001','Response in Progress',2,'Assigned Navy Rescue Boat A.','2026-09-09 15:30:29'),(5,'SN-2026-000003','Submitted',4,'Initial report submitted.','2026-09-09 15:30:29'),(6,'SN-2026-000003','Verified',2,'Multiple calls received regarding the same fire. Confirmed.','2026-09-09 15:30:29'),(7,'SN-2026-000003','Response in Progress',2,'Fire brigade dispatched.','2026-09-09 15:30:29'),(8,'SN-2026-000004','Submitted',7,'Initial report submitted by citizen','2026-09-09 16:06:10');
/*!40000 ALTER TABLE `archive_safenation_incident_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `archive_safenation_notifications`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_safenation_notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `type` varchar(50) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `related_id` varchar(50) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `archive_safenation_notif_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `archive_safenation_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archive_safenation_notifications`
--

LOCK TABLES `archive_safenation_notifications` WRITE;
/*!40000 ALTER TABLE `archive_safenation_notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `archive_safenation_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `archive_safenation_resources`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_safenation_resources` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `category` enum('Water','Food','Medicine','First Aid','Rescue Equipment','Blankets','Shelter Equipment','Vehicles','Communication Equipment','Other') NOT NULL,
  `quantity` decimal(10,2) NOT NULL DEFAULT 0.00,
  `unit` varchar(20) NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `location_name` varchar(255) DEFAULT NULL,
  `min_threshold` decimal(10,2) NOT NULL DEFAULT 0.00,
  `status` enum('Available','Low Stock','Critical','Out of Stock') DEFAULT 'Available',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archive_safenation_resources`
--

LOCK TABLES `archive_safenation_resources` WRITE;
/*!40000 ALTER TABLE `archive_safenation_resources` DISABLE KEYS */;
INSERT INTO `archive_safenation_resources` VALUES (1,'Drinking Water Bottles (1L)','Water',5000.00,'bottles',NULL,'DMC Main Warehouse',1000.00,'Available','2026-09-09 15:30:29','2026-09-09 15:30:29'),(2,'Dry Rations Pack','Food',250.00,'packs',NULL,'DMC Main Warehouse',500.00,'Low Stock','2026-09-09 15:30:29','2026-09-09 15:30:29'),(3,'First Aid Kits','First Aid',150.00,'kits',NULL,'DMC Main Warehouse',50.00,'Available','2026-09-09 15:30:29','2026-09-09 15:30:29'),(4,'Fleece Blankets','Blankets',20.00,'items',NULL,'DMC Main Warehouse',100.00,'Critical','2026-09-09 15:30:29','2026-09-09 15:30:29');
/*!40000 ALTER TABLE `archive_safenation_resources` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `archive_safenation_response_teams`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_safenation_response_teams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `current_location_lat` decimal(10,8) DEFAULT NULL,
  `current_location_lng` decimal(11,8) DEFAULT NULL,
  `status` enum('Available','Busy','Offline') DEFAULT 'Available',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archive_safenation_response_teams`
--

LOCK TABLES `archive_safenation_response_teams` WRITE;
/*!40000 ALTER TABLE `archive_safenation_response_teams` DISABLE KEYS */;
INSERT INTO `archive_safenation_response_teams` VALUES (1,'Colombo Fire & Rescue 1','Primary fire response unit',6.92710000,79.86120000,'Available','2026-09-09 15:30:29'),(2,'Navy Flood Rescue Boat A','Boat rescue for low lying areas',6.93880000,79.85110000,'Busy','2026-09-09 15:30:29');
/*!40000 ALTER TABLE `archive_safenation_response_teams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `archive_safenation_roles`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_safenation_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archive_safenation_roles`
--

LOCK TABLES `archive_safenation_roles` WRITE;
/*!40000 ALTER TABLE `archive_safenation_roles` DISABLE KEYS */;
INSERT INTO `archive_safenation_roles` VALUES (1,'Citizen','Standard citizen user'),(2,'Volunteer','Registered volunteer'),(3,'Authority','Disaster Management Authority'),(4,'Response Team','Emergency Response Team Member'),(5,'Hospital Staff','Hospital Administrator/Staff'),(6,'Administrator','System Administrator');
/*!40000 ALTER TABLE `archive_safenation_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `archive_safenation_shelters`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_safenation_shelters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `address` text NOT NULL,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  `contact` varchar(100) NOT NULL,
  `max_capacity` int(11) NOT NULL,
  `current_occupancy` int(11) DEFAULT 0,
  `facilities` text DEFAULT NULL,
  `accessibility` text DEFAULT NULL,
  `status` enum('Open','Full','Temporarily Closed','Emergency Only') DEFAULT 'Open',
  `updated_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `updated_by` (`updated_by`),
  CONSTRAINT `archive_safenation_shelters_ibfk_1` FOREIGN KEY (`updated_by`) REFERENCES `archive_safenation_users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archive_safenation_shelters`
--

LOCK TABLES `archive_safenation_shelters` WRITE;
/*!40000 ALTER TABLE `archive_safenation_shelters` DISABLE KEYS */;
INSERT INTO `archive_safenation_shelters` VALUES (1,'Royal College Sports Complex','Reid Avenue, Colombo 07',6.90380000,79.86110000,'+94112691025',500,120,'Water, Food, Toilets, Medical Desk','Wheelchair accessible','Open',2,'2026-09-09 15:30:29','2026-09-09 15:30:29'),(2,'Kelaniya Raja Maha Viharaya Hall','Kelaniya',6.95380000,79.91740000,'+94112911505',300,50,'Water, Food, Toilets','Ground floor only','Open',2,'2026-09-09 15:30:29','2026-09-09 15:30:29'),(3,'Sugathadasa Indoor Stadium','Arthur De Silva Mawatha, Colombo 13',6.94500000,79.86810000,'+94112431522',1000,0,'Water, Food, Showers, Toilets','Wheelchair accessible','Temporarily Closed',2,'2026-09-09 15:30:29','2026-09-09 15:30:29');
/*!40000 ALTER TABLE `archive_safenation_shelters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `archive_safenation_team_members`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_safenation_team_members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `team_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `role_in_team` varchar(50) DEFAULT 'Member',
  PRIMARY KEY (`id`),
  KEY `team_id` (`team_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `archive_safenation_team_mem_ibfk_1` FOREIGN KEY (`team_id`) REFERENCES `archive_safenation_response_teams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `archive_safenation_team_mem_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `archive_safenation_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archive_safenation_team_members`
--

LOCK TABLES `archive_safenation_team_members` WRITE;
/*!40000 ALTER TABLE `archive_safenation_team_members` DISABLE KEYS */;
INSERT INTO `archive_safenation_team_members` VALUES (1,1,5,'Commander');
/*!40000 ALTER TABLE `archive_safenation_team_members` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `archive_safenation_users`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_safenation_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `address` text DEFAULT NULL,
  `emergency_contact` varchar(255) DEFAULT NULL,
  `preferred_language` varchar(10) DEFAULT 'en',
  `status` enum('active','inactive','suspended') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `archive_safenation_users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `archive_safenation_roles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archive_safenation_users`
--

LOCK TABLES `archive_safenation_users` WRITE;
/*!40000 ALTER TABLE `archive_safenation_users` DISABLE KEYS */;
INSERT INTO `archive_safenation_users` VALUES (1,6,'System Admin','admin@safenation.lk','+94770000001','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Colombo 01','119','en','active','2026-09-09 15:30:29','2026-09-09 15:30:29'),(2,3,'Kamal Perera','authority@safenation.lk','+94770000002','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Disaster Management Centre, Colombo','+94112136136','en','active','2026-09-09 15:30:29','2026-09-09 15:30:29'),(3,1,'Nimal Fernando','citizen@safenation.lk','+94770000003','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','No 15, Galle Road, Rathmalana','+94770000123','en','active','2026-09-09 15:30:29','2026-09-09 15:30:29'),(4,2,'Sunil Silva','volunteer@safenation.lk','+94770000004','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Kandy Road, Kelaniya','+94770000124','en','active','2026-09-09 15:30:29','2026-09-09 15:30:29'),(5,4,'Rescue Team Alpha','response@safenation.lk','+94770000005','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Fire Station, Colombo 02','+94112422222','en','active','2026-09-09 15:30:29','2026-09-09 15:30:29'),(6,5,'Dr. Ruwani','hospital@safenation.lk','+94770000006','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','National Hospital Sri Lanka','+94112691111','en','active','2026-09-09 15:30:29','2026-09-09 15:30:29'),(7,1,'Ashvin','ashvin@gmail.com','0725127589','$2y$10$rCKnEDcs4cSYGazmT/tHausmNK8I2XKK2EHv8CZjFkXyel/3iggJu','no/23 main street ragala','0123456789','en','active','2026-09-09 16:00:51','2026-09-09 16:00:51');
/*!40000 ALTER TABLE `archive_safenation_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `archive_safenation_volunteer_assignments`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_safenation_volunteer_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `volunteer_id` int(11) NOT NULL,
  `incident_id` varchar(20) DEFAULT NULL,
  `task_description` text NOT NULL,
  `status` enum('Assigned','Accepted','En Route','In Progress','Completed','Declined','Cancelled') DEFAULT 'Assigned',
  `assigned_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `volunteer_id` (`volunteer_id`),
  KEY `incident_id` (`incident_id`),
  KEY `assigned_by` (`assigned_by`),
  CONSTRAINT `archive_safenation_vol_assign_ibfk_1` FOREIGN KEY (`volunteer_id`) REFERENCES `archive_safenation_volunteers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `archive_safenation_vol_assign_ibfk_2` FOREIGN KEY (`incident_id`) REFERENCES `archive_safenation_disaster_reports` (`incident_id`),
  CONSTRAINT `archive_safenation_vol_assign_ibfk_3` FOREIGN KEY (`assigned_by`) REFERENCES `archive_safenation_users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archive_safenation_volunteer_assignments`
--

LOCK TABLES `archive_safenation_volunteer_assignments` WRITE;
/*!40000 ALTER TABLE `archive_safenation_volunteer_assignments` DISABLE KEYS */;
/*!40000 ALTER TABLE `archive_safenation_volunteer_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `archive_safenation_volunteers`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archive_safenation_volunteers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `skills_summary` text DEFAULT NULL,
  `experience` text DEFAULT NULL,
  `availability_status` enum('Available','Busy','Offline') DEFAULT 'Offline',
  `preferred_area` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `archive_safenation_volunteers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `archive_safenation_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archive_safenation_volunteers`
--

LOCK TABLES `archive_safenation_volunteers` WRITE;
/*!40000 ALTER TABLE `archive_safenation_volunteers` DISABLE KEYS */;
INSERT INTO `archive_safenation_volunteers` VALUES (1,4,'First Aid, CPR, Swimming','3 years with Red Cross','Available','Colombo District','2026-09-09 15:30:29');
/*!40000 ALTER TABLE `archive_safenation_volunteers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assistance_requests`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assistance_requests` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `assigned_to` int(10) unsigned DEFAULT NULL,
  `category` varchar(40) NOT NULL,
  `description` text NOT NULL,
  `area` varchar(100) NOT NULL,
  `latitude` decimal(10,7) NOT NULL,
  `longitude` decimal(10,7) NOT NULL,
  `people` int(10) unsigned NOT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'submitted',
  `note` text NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `address` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `assigned_to` (`assigned_to`),
  KEY `status` (`status`),
  CONSTRAINT `assistance_requests_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `assistance_requests_ibfk_2` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assistance_requests`
--

LOCK TABLES `assistance_requests` WRITE;
/*!40000 ALTER TABLE `assistance_requests` DISABLE KEYS */;
INSERT INTO `assistance_requests` VALUES (1,3,5,'Food and water','Example request: a family needs food and drinking water after a flood.','Kandy',7.2900000,80.6300000,5,'assigned','A response team has been assigned to this example request.','2026-10-01 10:31:56','2026-10-01 10:31:56',''),(2,7,NULL,'Shelter','emergency safe shelter','Badulla',6.2906000,80.6337000,5,'submitted','','2026-10-01 11:14:50','2026-10-01 11:14:50',''),(3,8,5,'Medical assistance','need emergency kits and medicines for kids and elders.','Welimada',7.3023520,80.6352950,10,'submitted','please care of this problem imediatly','2026-10-04 12:32:23','2026-10-05 09:24:23','');
/*!40000 ALTER TABLE `assistance_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_logs`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `audit_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `entity` varchar(40) NOT NULL,
  `entity_id` int(10) unsigned DEFAULT NULL,
  `detail` text NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `created_at` (`created_at`),
  CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
INSERT INTO `audit_logs` VALUES (1,1,'installation_completed','users',1,'Academic demonstration data enabled','2026-10-01 10:31:56'),(2,2,'signed_in','users',2,'','2026-10-01 10:39:16'),(3,2,'signed_out','users',2,'','2026-10-01 10:47:44'),(4,1,'signed_in','users',1,'','2026-10-01 11:06:28'),(5,7,'registered','users',7,'','2026-10-01 11:13:40'),(6,7,'assistance_submitted','assistance_requests',2,'','2026-10-01 11:14:50'),(7,7,'signed_out','users',7,'','2026-10-01 11:19:02'),(8,1,'signed_in','users',1,'','2026-10-01 11:22:30'),(9,1,'settings_updated','settings',NULL,'','2026-10-01 11:23:12'),(10,1,'account_updated','users',2,'authority / active=1','2026-10-01 11:24:59'),(11,1,'facility_saved','facilities',5,'','2026-10-01 11:58:14'),(12,7,'signed_in','users',7,'','2026-10-02 08:45:26'),(13,7,'report_submitted','reports',5,'','2026-10-02 08:52:13'),(14,7,'signed_out','users',7,'','2026-10-02 08:52:49'),(15,1,'signed_in','users',1,'','2026-10-02 08:53:47'),(16,1,'settings_updated','settings',NULL,'','2026-10-02 08:55:01'),(17,1,'signed_out','users',1,'','2026-10-02 08:56:13'),(18,8,'registered','users',8,'','2026-10-04 12:20:32'),(19,8,'report_submitted','reports',6,'','2026-10-04 12:25:53'),(20,8,'assistance_submitted','assistance_requests',3,'','2026-10-04 12:32:23'),(21,1,'signed_in','users',1,'','2026-10-05 08:40:18'),(22,1,'signed_out','users',1,'','2026-10-05 08:44:57'),(23,1,'signed_in','users',1,'','2026-10-05 08:45:51'),(24,1,'signed_out','users',1,'','2026-10-05 08:46:13'),(25,1,'signed_in','users',1,'','2026-10-05 08:49:10'),(26,1,'signed_out','users',1,'','2026-10-05 08:52:45'),(27,2,'signed_in','users',2,'','2026-10-05 08:55:42'),(28,2,'report_reviewed','reports',4,'verified / Critical / Taking quick Action soon as possible','2026-10-05 09:10:47'),(29,2,'report_reviewed','reports',5,'resolved / Low / fixed the problem','2026-10-05 09:15:27'),(30,2,'report_details_updated','reports',5,'Heavy fire on whole building and that was get on control','2026-10-05 09:17:34'),(31,2,'report_reviewed','reports',6,'verified / Medium / taking action as soon as possible','2026-10-05 09:19:40'),(32,2,'response_updated','reports',6,'monitoring: Tryin to safe the people on safe places','2026-10-05 09:20:37'),(33,2,'response_updated','reports',6,'monitoring: safe the people','2026-10-05 09:21:08'),(34,2,'request_updated','assistance_requests',3,'submitted: please care of this problem imediatly','2026-10-05 09:24:23'),(35,2,'facility_saved','facilities',4,'','2026-10-05 09:30:37'),(36,2,'facility_saved','facilities',5,'','2026-10-05 09:31:12'),(37,2,'signed_out','users',2,'','2026-10-05 09:33:47'),(38,4,'signed_in','users',4,'','2026-10-05 09:34:01'),(39,4,'volunteer_profile_saved','volunteers',4,'','2026-10-05 09:35:03'),(40,4,'volunteer_profile_saved','volunteers',4,'','2026-10-05 09:35:37'),(41,4,'assignment_updated','volunteer_assignments',1,'accepted','2026-10-05 09:55:14'),(42,4,'assignment_updated','volunteer_assignments',1,'in_progress','2026-10-05 09:55:45'),(43,4,'assignment_updated','volunteer_assignments',1,'completed','2026-10-05 09:55:49'),(44,4,'signed_out','users',4,'','2026-10-05 09:57:12'),(45,2,'signed_in','users',2,'','2026-10-05 09:57:25'),(46,2,'signed_out','users',2,'','2026-10-05 10:57:53'),(47,2,'signed_in','users',2,'','2026-10-05 10:58:04'),(48,2,'resource_created','resources',5,'','2026-10-05 10:59:43'),(49,2,'resource_received','resources',4,'1 litres / kandy','2026-10-05 11:00:57'),(50,2,'signed_out','users',2,'','2026-10-05 11:04:46'),(51,1,'signed_in','users',1,'','2026-10-05 11:05:01'),(52,1,'profile_updated','users',1,'','2026-10-05 11:08:54'),(53,1,'response_updated','reports',3,'monitoring: we fix it as soon as possible','2026-10-05 11:12:30'),(54,NULL,'hospital_directory_imported','facilities',NULL,'Added 25 hospital directory entries across 25 districts; existing records preserved.','2026-10-08 07:50:41'),(55,2,'signed_in','users',2,'','2026-10-08 09:24:38'),(56,2,'signed_out','users',2,'','2026-10-08 09:26:41'),(57,1,'password_reset_local','users',1,'Administrator password reset locally at account owner request.','2026-10-08 20:07:15'),(58,1,'signed_in','users',1,'','2026-10-08 20:07:16'),(59,1,'signed_out','users',1,'','2026-10-08 20:07:16'),(60,1,'signed_in','users',1,'','2026-10-08 20:22:52'),(61,1,'signed_out','users',1,'','2026-10-08 21:24:50');
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `disaster_types`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `disaster_types` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(60) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `disaster_types`
--

LOCK TABLES `disaster_types` WRITE;
/*!40000 ALTER TABLE `disaster_types` DISABLE KEYS */;
INSERT INTO `disaster_types` VALUES (4,'Fire'),(1,'Flood'),(5,'Heavy rainfall'),(2,'Landslide'),(6,'Other'),(3,'Storm');
/*!40000 ALTER TABLE `disaster_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `facilities`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `facilities` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `manager_id` int(10) unsigned DEFAULT NULL,
  `kind` varchar(20) NOT NULL,
  `name` varchar(150) NOT NULL,
  `area` varchar(100) NOT NULL,
  `address` varchar(255) NOT NULL,
  `latitude` decimal(10,7) NOT NULL,
  `longitude` decimal(10,7) NOT NULL,
  `capacity` int(10) unsigned NOT NULL DEFAULT 0,
  `occupancy` int(10) unsigned NOT NULL DEFAULT 0,
  `services` text NOT NULL,
  `phone` varchar(30) NOT NULL,
  `emergency_service` tinyint(1) NOT NULL DEFAULT 0,
  `status` varchar(20) NOT NULL DEFAULT 'open',
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `capacity_known` tinyint(1) NOT NULL DEFAULT 1,
  `source_code` varchar(100) DEFAULT NULL,
  `source_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `source_code` (`source_code`),
  KEY `manager_id` (`manager_id`),
  KEY `kind` (`kind`,`status`,`area`),
  CONSTRAINT `facilities_ibfk_1` FOREIGN KEY (`manager_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `facilities`
--

LOCK TABLES `facilities` WRITE;
/*!40000 ALTER TABLE `facilities` DISABLE KEYS */;
INSERT INTO `facilities` VALUES (1,6,'shelter','Kandy Community Shelter (example)','Kandy','Example location, Kandy (not a real facility address)',7.2960000,80.6380000,120,36,'Example services: drinking water, accessible entrance, sanitation','No real contact number',0,'open','2026-10-01 10:31:55',1,NULL,NULL),(2,6,'hospital','Central Emergency Hospital (example)','Kandy','Example location, Kandy (not a real facility address)',7.2810000,80.6200000,60,28,'Example services: emergency care, first aid, accessible entrance','No real contact number',1,'open','2026-10-01 10:31:55',1,NULL,NULL),(3,6,'shelter','Hill Country Shelter (example)','Nuwara Eliya','Example location, Nuwara Eliya (not a real facility address)',6.9600000,80.7800000,80,67,'Example services: beds, drinking water, sanitation','No real contact number',0,'limited','2026-10-01 10:31:55',1,NULL,NULL),(4,6,'hospital','Colombo Care Centre (example)','Colombo','Example location, Colombo (not a real facility address)',6.9200000,79.8700000,100,45,'Example services: medical triage, emergency care','No real contact number',1,'open','2026-10-01 10:31:55',1,NULL,NULL),(5,NULL,'shelter','All Facilities With Hosipital Needs','Jaffna','Nalloor Rd, No 134,Jaffna',7.3023520,80.6352950,3,3,'Example services: drinking water, accessible entrance, sanitation','0781000003',0,'open','2026-10-05 09:31:12',1,NULL,NULL),(6,NULL,'hospital','District General Hospital Ampara','Ampara','Ampara, Ampara District, Sri Lanka',7.2989499,81.6892024,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:node:4741177121','https://www.openstreetmap.org/node/4741177121'),(7,NULL,'hospital','Teaching Hospital Anuradhapura','Anuradhapura','Anuradhapura, Anuradhapura District, Sri Lanka',8.3257683,80.4133858,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:way:102371565','https://www.openstreetmap.org/way/102371565'),(8,NULL,'hospital','Teaching Hospital Badulla','Badulla','Bandarawela Road, Badulla, Badulla District, Sri Lanka',6.9916586,81.0520165,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:way:1229701727','https://www.openstreetmap.org/way/1229701727'),(9,NULL,'hospital','Teaching Hospital Batticaloa','Batticaloa','Hospital Road, Batticaloa, Batticaloa District, Sri Lanka',7.7075124,81.6905875,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:way:232761550','https://www.openstreetmap.org/way/232761550'),(10,NULL,'hospital','National Hospital of Sri Lanka','Colombo','Colombo, Colombo District, Sri Lanka',6.9183968,79.8681975,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:way:355252669','https://www.openstreetmap.org/way/355252669'),(11,NULL,'hospital','National Hospital Galle (Karapitiya)','Galle','Karapitiya, Galle, Galle District, Sri Lanka',6.0665677,80.2258090,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:way:151406006','https://www.openstreetmap.org/way/151406006'),(12,NULL,'hospital','District General Hospital Gampaha','Gampaha','Gampaha, Gampaha District, Sri Lanka',7.0913115,80.0010683,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:way:204765569','https://www.openstreetmap.org/way/204765569'),(13,NULL,'hospital','District General Hospital Hambantota','Hambantota','Hambantota, Hambantota District, Sri Lanka',6.1564964,81.1098087,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:way:539159086','https://www.openstreetmap.org/way/539159086'),(14,NULL,'hospital','Teaching Hospital Jaffna','Jaffna','Hospital Road, Jaffna, Jaffna District, Sri Lanka',9.6664322,80.0127075,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:node:5185617923','https://www.openstreetmap.org/node/5185617923'),(15,NULL,'hospital','Teaching Hospital Kalutara','Kalutara','Nagoda, Kalutara, Kalutara District, Sri Lanka',6.5630625,79.9852435,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:node:1823709276','https://www.openstreetmap.org/node/1823709276'),(16,NULL,'hospital','National Hospital Kandy','Kandy','William Gopallawa Mawatha, Kandy, Kandy District, Sri Lanka',7.2864399,80.6316756,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:way:572962990','https://www.openstreetmap.org/way/572962990'),(17,NULL,'hospital','District General Hospital Kegalle','Kegalle','Kegalle, Kegalle District, Sri Lanka',7.2474985,80.3457050,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:node:3220016706','https://www.openstreetmap.org/node/3220016706'),(18,NULL,'hospital','District General Hospital Kilinochchi','Kilinochchi','Kilinochchi, Kilinochchi District, Sri Lanka',9.3727442,80.4114281,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:node:2152832489','https://www.openstreetmap.org/node/2152832489'),(19,NULL,'hospital','Teaching Hospital Kurunegala','Kurunegala','Kurunegala, Kurunegala District, Sri Lanka',7.4790195,80.3583528,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:node:11155256557','https://www.openstreetmap.org/node/11155256557'),(20,NULL,'hospital','District General Hospital Mannar','Mannar','Thalvupadu - Mannar Rd, Mannar, Mannar District, Sri Lanka',8.9813545,79.9028820,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:node:3424999527','https://www.openstreetmap.org/node/3424999527'),(21,NULL,'hospital','District General Hospital Matale','Matale','Matale, Matale District, Sri Lanka',7.4619989,80.6252338,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:way:495870313','https://www.openstreetmap.org/way/495870313'),(22,NULL,'hospital','District General Hospital Matara','Matara','Matara, Matara District, Sri Lanka',5.9479329,80.5497116,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:way:362364038','https://www.openstreetmap.org/way/362364038'),(23,NULL,'hospital','Divisional Hospital Buttala','Monaragala','Colombo - Ratnapura - Wellawaya - Batticaloa Road, Buttala, Monaragala District, Sri Lanka',6.7581389,81.2397961,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:way:354253532','https://www.openstreetmap.org/way/354253532'),(24,NULL,'hospital','Divisional Hospital Oddusuddan','Mullaitivu','Oddusuddan, Mullaitivu District, Sri Lanka',9.1627819,80.6604767,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:node:4124124130','https://www.openstreetmap.org/node/4124124130'),(25,NULL,'hospital','District General Hospital Nuwara Eliya','Nuwara Eliya','Nuwara Eliya, Nuwara Eliya District, Sri Lanka',6.9741094,80.7803117,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:node:873842128','https://www.openstreetmap.org/node/873842128'),(26,NULL,'hospital','District General Hospital Polonnaruwa','Polonnaruwa','Polonnaruwa, Polonnaruwa District, Sri Lanka',7.9432754,81.0093775,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:way:276745101','https://www.openstreetmap.org/way/276745101'),(27,NULL,'hospital','District General Hospital Chilaw','Puttalam','Chilaw, Puttalam District, Sri Lanka',7.5719944,79.7974227,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:way:593951422','https://www.openstreetmap.org/way/593951422'),(28,NULL,'hospital','Teaching Hospital Ratnapura','Ratnapura','Ratnapura, Ratnapura District, Sri Lanka',6.6871447,80.3924992,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:node:1994920168','https://www.openstreetmap.org/node/1994920168'),(29,NULL,'hospital','District General Hospital Trincomalee','Trincomalee','Trincomalee, Trincomalee District, Sri Lanka',8.5641426,81.2396356,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:way:108344847','https://www.openstreetmap.org/way/108344847'),(30,NULL,'hospital','District General Hospital Vavuniya','Vavuniya','Vavuniya, Vavuniya District, Sri Lanka',8.7618394,80.4996628,0,0,'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded',0,'unknown','2026-10-08 07:50:41',0,'healthsites:way:699018543','https://www.openstreetmap.org/way/699018543');
/*!40000 ALTER TABLE `facilities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `login_attempts`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `login_attempts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `fingerprint` char(64) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fingerprint` (`fingerprint`,`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `login_attempts`
--

LOCK TABLES `login_attempts` WRITE;
/*!40000 ALTER TABLE `login_attempts` DISABLE KEYS */;
INSERT INTO `login_attempts` VALUES (1,'c2f162e6bd819c0dd033935a1df036e8540b08c6cdaa0b74a98f49943c9c866d','2026-10-01 11:10:37');
/*!40000 ALTER TABLE `login_attempts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifications` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `title` varchar(150) NOT NULL,
  `message` text NOT NULL,
  `link` varchar(200) NOT NULL,
  `read_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`,`read_at`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,1,'Welcome to SafeNation','Welcome to SafeNation. Use your dashboard to view reports, requests and assignments. Records marked as examples are for project testing.','index.php?page=dashboard',NULL,'2026-10-01 10:31:56'),(2,2,'Welcome to SafeNation','Welcome to SafeNation. Use your dashboard to view reports, requests and assignments. Records marked as examples are for project testing.','index.php?page=dashboard',NULL,'2026-10-01 10:31:56'),(3,3,'Welcome to SafeNation','Welcome to SafeNation. Use your dashboard to view reports, requests and assignments. Records marked as examples are for project testing.','index.php?page=dashboard',NULL,'2026-10-01 10:31:56'),(4,4,'Welcome to SafeNation','Welcome to SafeNation. Use your dashboard to view reports, requests and assignments. Records marked as examples are for project testing.','index.php?page=dashboard','2026-10-05 09:52:34','2026-10-01 10:31:56'),(5,5,'Welcome to SafeNation','Welcome to SafeNation. Use your dashboard to view reports, requests and assignments. Records marked as examples are for project testing.','index.php?page=dashboard',NULL,'2026-10-01 10:31:56'),(6,6,'Welcome to SafeNation','Welcome to SafeNation. Use your dashboard to view reports, requests and assignments. Records marked as examples are for project testing.','index.php?page=dashboard',NULL,'2026-10-01 10:31:56'),(7,1,'New assistance request','Request #2 needs review.','index.php?page=assistance',NULL,'2026-10-01 11:14:50'),(8,2,'New assistance request','Request #2 needs review.','index.php?page=assistance',NULL,'2026-10-01 11:14:50'),(9,1,'New incident report','Report #5 awaits verification.','index.php?page=report&id=5',NULL,'2026-10-02 08:52:13'),(10,2,'New incident report','Report #5 awaits verification.','index.php?page=report&id=5',NULL,'2026-10-02 08:52:13'),(11,1,'New incident report','Report #6 awaits verification.','index.php?page=report&id=6',NULL,'2026-10-04 12:25:53'),(12,2,'New incident report','Report #6 awaits verification.','index.php?page=report&id=6',NULL,'2026-10-04 12:25:53'),(13,1,'New assistance request','Request #3 needs review.','index.php?page=assistance',NULL,'2026-10-04 12:32:23'),(14,2,'New assistance request','Request #3 needs review.','index.php?page=assistance',NULL,'2026-10-04 12:32:23'),(15,3,'Report status updated','Report #4 is now verified. Taking quick Action soon as possible','index.php?page=report&id=4',NULL,'2026-10-05 09:10:47'),(16,7,'Report status updated','Report #5 is now resolved. fixed the problem','index.php?page=report&id=5',NULL,'2026-10-05 09:15:27'),(17,7,'Incident details updated','Report #5: Heavy fire on whole building and that was get on control','index.php?page=report&id=5',NULL,'2026-10-05 09:17:34'),(18,8,'Report status updated','Report #6 is now verified. taking action as soon as possible','index.php?page=report&id=6',NULL,'2026-10-05 09:19:40'),(19,8,'Response update','Report #6: monitoring. Tryin to safe the people on safe places','index.php?page=report&id=6',NULL,'2026-10-05 09:20:37'),(20,8,'Response update','Report #6: monitoring. safe the people','index.php?page=report&id=6',NULL,'2026-10-05 09:21:08'),(21,8,'Assistance request updated','Request #3: submitted. please care of this problem imediatly','index.php?page=assistance',NULL,'2026-10-05 09:24:23'),(22,5,'Assistance assignment','Request #3: submitted. please care of this problem imediatly','index.php?page=assistance',NULL,'2026-10-05 09:24:23'),(23,2,'Assignment status updated','Assignment #1: accepted','index.php?page=volunteers',NULL,'2026-10-05 09:55:14'),(24,2,'Assignment status updated','Assignment #1: in_progress','index.php?page=volunteers',NULL,'2026-10-05 09:55:45'),(25,2,'Assignment status updated','Assignment #1: completed','index.php?page=volunteers',NULL,'2026-10-05 09:55:49'),(26,3,'Response update','Report #3: monitoring. we fix it as soon as possible','index.php?page=report&id=3',NULL,'2026-10-05 11:12:30');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_reviews`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `report_reviews` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `report_id` int(10) unsigned NOT NULL,
  `reviewer_id` int(10) unsigned NOT NULL,
  `status` varchar(20) NOT NULL,
  `severity` varchar(16) NOT NULL,
  `note` text NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `report_id` (`report_id`),
  KEY `reviewer_id` (`reviewer_id`),
  CONSTRAINT `report_reviews_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`),
  CONSTRAINT `report_reviews_ibfk_2` FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_reviews`
--

LOCK TABLES `report_reviews` WRITE;
/*!40000 ALTER TABLE `report_reviews` DISABLE KEYS */;
INSERT INTO `report_reviews` VALUES (1,1,2,'verified','High','Reviewed as an example incident for project testing.','2026-10-01 10:31:55'),(2,2,2,'verified','High','Reviewed as an example incident for project testing.','2026-10-01 10:31:55'),(3,3,2,'verified','Low','Reviewed as an example incident for project testing.','2026-10-01 10:31:55'),(4,4,2,'verified','Critical','Taking quick Action soon as possible','2026-10-05 09:10:47'),(5,5,2,'resolved','Low','fixed the problem','2026-10-05 09:15:27'),(6,5,2,'resolved','Low','Incident details updated: Heavy fire on whole building and that was get on control','2026-10-05 09:17:34'),(7,6,2,'verified','Medium','taking action as soon as possible','2026-10-05 09:19:40');
/*!40000 ALTER TABLE `report_reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reports`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reports` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `type_id` int(10) unsigned NOT NULL,
  `title` varchar(150) NOT NULL,
  `description` text NOT NULL,
  `area` varchar(100) NOT NULL,
  `latitude` decimal(10,7) NOT NULL,
  `longitude` decimal(10,7) NOT NULL,
  `occurred_at` datetime NOT NULL,
  `affected_people` int(10) unsigned NOT NULL DEFAULT 0,
  `damage` varchar(30) NOT NULL DEFAULT 'none',
  `ai_severity` varchar(16) NOT NULL,
  `ai_reason` text NOT NULL,
  `severity` varchar(16) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'pending',
  `response_status` varchar(30) NOT NULL DEFAULT 'monitoring',
  `duplicate_of` int(10) unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `address` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `duplicate_of` (`duplicate_of`),
  KEY `status` (`status`,`severity`),
  KEY `type_id` (`type_id`,`created_at`),
  KEY `area` (`area`),
  CONSTRAINT `reports_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `reports_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `disaster_types` (`id`),
  CONSTRAINT `reports_ibfk_3` FOREIGN KEY (`duplicate_of`) REFERENCES `reports` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reports`
--

LOCK TABLES `reports` WRITE;
/*!40000 ALTER TABLE `reports` DISABLE KEYS */;
INSERT INTO `reports` VALUES (1,3,1,'Example incident: rising water near a community road','Example record: floodwater has blocked access to homes. Several people need assistance.','Kandy',7.2906000,80.6337000,'2026-10-01 08:31:55',38,'moderate','High','25–99 people reported affected; moderate reported damage','High','verified','monitoring',NULL,'2026-10-01 10:31:55','2026-10-01 10:31:55',''),(2,3,2,'Example incident: slope movement after rain','Example record: soil has moved beside a road after heavy rain. No injuries have been reported.','Nuwara Eliya',6.9497000,80.7891000,'2026-10-01 08:31:55',8,'moderate','High','5–24 people reported affected; moderate reported damage; hazard category warrants additional attention','High','verified','monitoring',NULL,'2026-09-30 10:31:55','2026-10-01 10:31:55',''),(3,3,3,'Example incident: local storm damage','Example record: fallen branches have blocked a lane. Minor property damage has been reported.','Colombo',6.9271000,79.8612000,'2026-10-01 08:31:55',4,'minor','Low','minor reported damage','Low','verified','monitoring',NULL,'2026-09-29 10:31:55','2026-10-01 10:31:55',''),(4,3,4,'Example incident: building fire requiring urgent review','Example record: fire has spread through a building. People are trapped and injured.','Matale',7.4675000,80.6234000,'2026-10-01 08:31:55',120,'severe','Critical','100 or more people reported affected; severe reported damage; hazard category warrants additional attention; reported signal: trapped; reported signal: injured','Critical','verified','monitoring',NULL,'2026-09-28 10:31:55','2026-10-05 09:10:47',''),(5,7,4,'Fire on building','Heavy fire on whole building','Badulla',7.2906000,80.6337000,'2026-10-02 08:51:00',0,'none','Low','hazard category warrants additional attention','Low','resolved','monitoring',NULL,'2026-10-02 08:52:13','2026-10-05 09:17:34',''),(6,8,5,'Landslide','Big landslide on our main road ,so here many of suffering to travel and identify safe places','Welimada',7.2906000,80.6337000,'2026-10-04 12:22:00',18,'minor','Medium','5–24 people reported affected; minor reported damage','Medium','verified','monitoring',NULL,'2026-10-04 12:25:53','2026-10-05 09:19:40','');
/*!40000 ALTER TABLE `reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resource_transactions`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resource_transactions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `resource_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `kind` varchar(20) NOT NULL,
  `quantity` decimal(12,2) unsigned NOT NULL,
  `destination` varchar(150) NOT NULL,
  `note` text NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `resource_id` (`resource_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `resource_transactions_ibfk_1` FOREIGN KEY (`resource_id`) REFERENCES `resources` (`id`),
  CONSTRAINT `resource_transactions_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resource_transactions`
--

LOCK TABLES `resource_transactions` WRITE;
/*!40000 ALTER TABLE `resource_transactions` DISABLE KEYS */;
INSERT INTO `resource_transactions` VALUES (1,1,1,'received',800.00,'Example opening stock','Example inventory for project testing','2026-10-01 10:31:55'),(2,2,1,'received',140.00,'Example opening stock','Example inventory for project testing','2026-10-01 10:31:56'),(3,3,1,'received',12.00,'Example opening stock','Example inventory for project testing','2026-10-01 10:31:56'),(4,4,1,'received',200.00,'Example opening stock','Example inventory for project testing','2026-10-01 10:31:56'),(5,4,2,'received',1.00,'kandy','water','2026-10-05 11:00:57');
/*!40000 ALTER TABLE `resource_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resources`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resources` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `category` varchar(40) NOT NULL,
  `unit` varchar(30) NOT NULL,
  `location` varchar(100) NOT NULL,
  `quantity` decimal(12,2) unsigned NOT NULL DEFAULT 0.00,
  `minimum_quantity` decimal(12,2) unsigned NOT NULL DEFAULT 0.00,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resources`
--

LOCK TABLES `resources` WRITE;
/*!40000 ALTER TABLE `resources` DISABLE KEYS */;
INSERT INTO `resources` VALUES (1,'Drinking water','Water','litres','Kandy depot',800.00,200.00,'2026-10-01 10:31:55'),(2,'Family food packs','Food','packs','Kandy depot',140.00,50.00,'2026-10-01 10:31:55'),(3,'First-aid kits','Medicine','kits','Central depot',12.00,15.00,'2026-10-01 10:31:56'),(4,'Drinking water','Water','litres','Colombo depot',201.00,100.00,'2026-10-05 11:00:57'),(5,'Safety kits','Medicine','45','Kandy depot',0.00,0.06,'2026-10-05 10:59:43');
/*!40000 ALTER TABLE `resources` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `name` varchar(32) NOT NULL,
  `label` varchar(80) NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES ('admin','Administrator'),('authority','Authority'),('citizen','Citizen'),('facility_manager','Facility manager'),('responder','Emergency response team'),('volunteer','Volunteer');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `settings` (
  `name` varchar(80) NOT NULL,
  `value` text NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES ('announcement','Our project includes labelled example records. Hospital directory availability must be confirmed with the hospital.'),('site_name','SafeNation');
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(190) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` varchar(32) NOT NULL DEFAULT 'citizen',
  `phone` varchar(30) NOT NULL DEFAULT '',
  `area` varchar(100) NOT NULL DEFAULT '',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `role` (`role`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role`) REFERENCES `roles` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'SafeNation Administrator','admin@safenation.local','$2y$10$dYj8lwdPx0gCixG326SmMu0Z6RDk5Vl5wNL1qBnXDAI5vbHQkGoUy','admin','','Kandy',1,'2026-10-01 10:31:55'),(2,'Authority Coordinator','authority@example.test','$2y$10$VQ2SCT302mp8sFtPHzTOTerD96997WMWzYrs6mAPFXL6aqi5WtYsO','authority','','Kandy',1,'2026-10-01 10:31:55'),(3,'Citizen User','citizen@example.test','$2y$10$ejOW2lqwSvR5cL.ojfPL7.PFYIa1hf6OKrnQzJ0cCGGOIX513pEUm','citizen','','Kandy',1,'2026-10-01 10:31:55'),(4,'Volunteer User','volunteer@example.test','$2y$10$IfMQovLeJGYHJT52mW1zeOtdBAioCYMnVymUgKVqplnFHf6ugaeRG','volunteer','','Kandy',1,'2026-10-01 10:31:55'),(5,'Response Team','responder@example.test','$2y$10$Pfq6LRWHc3Wox6OHUZccb.poBps4D3bMtyUbYNFW/ZC15BMFyxzRG','responder','','Kandy',1,'2026-10-01 10:31:55'),(6,'Facility Manager','facility@example.test','$2y$10$HarSZr7mQtuNZmoYOcR5GOAAoadSOVMhORzidAx2yNfCEj/MlQZWa','facility_manager','','Kandy',1,'2026-10-01 10:31:55'),(7,'Rushini','rushini@gmail.com','$2y$10$LZjZb/9UwVzEpfqcx6uAYucM6a0JowipIoIg19KCc174NIdTgarYq','citizen','0740000002','Badulla',1,'2026-10-01 11:13:40'),(8,'Minhaj','minhajmhd845@gmail.com','$2y$10$H3t/vFskZpAOo5srNGOGKu2R2lCuwATIdpCt1BxU10Yb0Ed/LqGMS','citizen','0701234555','Welimada',1,'2026-10-04 12:20:32');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `volunteer_assignments`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `volunteer_assignments` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `volunteer_id` int(10) unsigned NOT NULL,
  `report_id` int(10) unsigned DEFAULT NULL,
  `coordinator_id` int(10) unsigned NOT NULL,
  `title` varchar(150) NOT NULL,
  `instructions` text NOT NULL,
  `area` varchar(100) NOT NULL,
  `due_at` datetime NOT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'assigned',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `volunteer_id` (`volunteer_id`),
  KEY `report_id` (`report_id`),
  KEY `coordinator_id` (`coordinator_id`),
  CONSTRAINT `volunteer_assignments_ibfk_1` FOREIGN KEY (`volunteer_id`) REFERENCES `volunteers` (`user_id`),
  CONSTRAINT `volunteer_assignments_ibfk_2` FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`),
  CONSTRAINT `volunteer_assignments_ibfk_3` FOREIGN KEY (`coordinator_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `volunteer_assignments`
--

LOCK TABLES `volunteer_assignments` WRITE;
/*!40000 ALTER TABLE `volunteer_assignments` DISABLE KEYS */;
INSERT INTO `volunteer_assignments` VALUES (1,4,1,2,'Example assignment: coordinate shelter supplies','Example assignment for project testing. Check the example shelter inventory and contact the assigned coordinator.','Kandy','2026-10-08 10:31:56','completed','2026-10-01 10:31:56');
/*!40000 ALTER TABLE `volunteer_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `volunteers`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `volunteers` (
  `user_id` int(10) unsigned NOT NULL,
  `skills` varchar(255) NOT NULL,
  `experience` text NOT NULL,
  `availability` varchar(30) NOT NULL,
  `service_area` varchar(100) NOT NULL,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `volunteers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `volunteers`
--

LOCK TABLES `volunteers` WRITE;
/*!40000 ALTER TABLE `volunteers` DISABLE KEYS */;
INSERT INTO `volunteers` VALUES (4,'First aid, logistics, translation','Example volunteer profile for first aid, logistics and translation.','available','Kandy');
/*!40000 ALTER TABLE `volunteers` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-09 16:55:24
