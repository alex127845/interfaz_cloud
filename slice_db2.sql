-- MySQL dump 10.13  Distrib 8.0.36, for Win64 (x86_64)
--
-- Host: localhost    Database: mydb
-- ------------------------------------------------------
-- Server version	8.0.36

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `enlace`
--

DROP TABLE IF EXISTS `enlace`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `enlace` (
  `idenlace` int NOT NULL,
  `vm1` varchar(45) DEFAULT NULL,
  `vm2` varchar(45) DEFAULT NULL,
  `vlan` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`idenlace`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enlace`
--

LOCK TABLES `enlace` WRITE;
/*!40000 ALTER TABLE `enlace` DISABLE KEYS */;
/*!40000 ALTER TABLE `enlace` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `imagen`
--

DROP TABLE IF EXISTS `imagen`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `imagen` (
  `idimagen` int NOT NULL,
  `ruta` varchar(45) DEFAULT NULL,
  `nombre` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`idimagen`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `imagen`
--

LOCK TABLES `imagen` WRITE;
/*!40000 ALTER TABLE `imagen` DISABLE KEYS */;
/*!40000 ALTER TABLE `imagen` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `instancia`
--

DROP TABLE IF EXISTS `instancia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `instancia` (
  `idinstancia` int NOT NULL AUTO_INCREMENT,
  `slice_idslice` int NOT NULL,
  `nombre` varchar(100) DEFAULT NULL,
  `estado` varchar(45) DEFAULT NULL,
  `cpu` varchar(45) DEFAULT NULL,
  `ram` varchar(45) DEFAULT NULL,
  `storage` varchar(45) DEFAULT NULL,
  `salidainternet` tinyint DEFAULT NULL,
  `imagen_idimagen` int NOT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `vnc_idvnc` int DEFAULT NULL,
  `worker_idworker` int DEFAULT NULL,
  PRIMARY KEY (`idinstancia`,`slice_idslice`),
  KEY `fk_instancia_slice1_idx` (`slice_idslice`),
  KEY `fk_instancia_imagen1_idx` (`imagen_idimagen`),
  KEY `fk_instancia_vnc1_idx` (`vnc_idvnc`),
  KEY `fk_instancia_worker1_idx` (`worker_idworker`),
  CONSTRAINT `fk_instancia_imagen1` FOREIGN KEY (`imagen_idimagen`) REFERENCES `imagen` (`idimagen`),
  CONSTRAINT `fk_instancia_slice1` FOREIGN KEY (`slice_idslice`) REFERENCES `slice` (`idslice`),
  CONSTRAINT `fk_instancia_vnc1` FOREIGN KEY (`vnc_idvnc`) REFERENCES `vnc` (`idvnc`),
  CONSTRAINT `fk_instancia_worker1` FOREIGN KEY (`worker_idworker`) REFERENCES `worker` (`idworker`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `instancia`
--

LOCK TABLES `instancia` WRITE;
/*!40000 ALTER TABLE `instancia` DISABLE KEYS */;
/*!40000 ALTER TABLE `instancia` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rol`
--

DROP TABLE IF EXISTS `rol`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rol` (
  `idrol` int NOT NULL AUTO_INCREMENT,
  `nombre_rol` varchar(45) NOT NULL,
  PRIMARY KEY (`idrol`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rol`
--

LOCK TABLES `rol` WRITE;
/*!40000 ALTER TABLE `rol` DISABLE KEYS */;
INSERT INTO `rol` VALUES (1,'superadmin'),(2,'administrador'),(3,'investigador'),(4,'usuariofinal');
/*!40000 ALTER TABLE `rol` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `slice`
--

DROP TABLE IF EXISTS `slice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `slice` (
  `idslice` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) DEFAULT NULL,
  `estado` varchar(45) DEFAULT NULL,
  `topologia` text,
  `fecha_creacion` date DEFAULT NULL,
  `fecha_upload` date DEFAULT NULL,
  `zonadisponibilidad` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`idslice`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `slice`
--

LOCK TABLES `slice` WRITE;
/*!40000 ALTER TABLE `slice` DISABLE KEYS */;
/*!40000 ALTER TABLE `slice` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario` (
  `idusuario` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(45) DEFAULT NULL,
  `contrasenia` varchar(128) DEFAULT NULL,
  `rol_idrol` int NOT NULL,
  PRIMARY KEY (`idusuario`,`rol_idrol`),
  KEY `fk_usuario_rol1_idx` (`rol_idrol`),
  CONSTRAINT `fk_usuario_rol1` FOREIGN KEY (`rol_idrol`) REFERENCES `rol` (`idrol`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario`
--

LOCK TABLES `usuario` WRITE;
/*!40000 ALTER TABLE `usuario` DISABLE KEYS */;
INSERT INTO `usuario` VALUES (1,'admin','admin123',1),(2,'ricardo','ricardo123',2),(3,'roberto','roberto123',3),(4,'adrian','adrian123',4);
/*!40000 ALTER TABLE `usuario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario_has_slice`
--

DROP TABLE IF EXISTS `usuario_has_slice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario_has_slice` (
  `usuario_idusuario` int NOT NULL,
  `slice_idslice` int NOT NULL,
  PRIMARY KEY (`usuario_idusuario`,`slice_idslice`),
  KEY `fk_usuario_has_slice_slice1_idx` (`slice_idslice`),
  KEY `fk_usuario_has_slice_usuario1_idx` (`usuario_idusuario`),
  CONSTRAINT `fk_usuario_has_slice_slice1` FOREIGN KEY (`slice_idslice`) REFERENCES `slice` (`idslice`),
  CONSTRAINT `fk_usuario_has_slice_usuario1` FOREIGN KEY (`usuario_idusuario`) REFERENCES `usuario` (`idusuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario_has_slice`
--

LOCK TABLES `usuario_has_slice` WRITE;
/*!40000 ALTER TABLE `usuario_has_slice` DISABLE KEYS */;
/*!40000 ALTER TABLE `usuario_has_slice` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vlan`
--

DROP TABLE IF EXISTS `vlan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vlan` (
  `idvlan` int NOT NULL,
  `numero` varchar(45) DEFAULT NULL,
  `estado` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`idvlan`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vlan`
--

LOCK TABLES `vlan` WRITE;
/*!40000 ALTER TABLE `vlan` DISABLE KEYS */;
INSERT INTO `vlan` VALUES (1,'100','ocupada'),(2,'101','ocupada'),(3,'102','ocupada'),(4,'103','ocupada'),(5,'104','disponible'),(6,'105','disponible'),(7,'106','disponible'),(8,'107','disponible'),(9,'108','disponible'),(10,'109','disponible'),(11,'110','disponible');
/*!40000 ALTER TABLE `vlan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vnc`
--

DROP TABLE IF EXISTS `vnc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vnc` (
  `idvnc` int NOT NULL,
  `puerto` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`idvnc`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vnc`
--

LOCK TABLES `vnc` WRITE;
/*!40000 ALTER TABLE `vnc` DISABLE KEYS */;
/*!40000 ALTER TABLE `vnc` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `worker`
--

DROP TABLE IF EXISTS `worker`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `worker` (
  `idworker` int NOT NULL,
  `nombre` varchar(45) DEFAULT NULL,
  `puerto` varchar(45) DEFAULT NULL,
  `cpu` varchar(45) DEFAULT NULL,
  `ram` varchar(45) DEFAULT NULL,
  `storage` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`idworker`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `worker`
--

LOCK TABLES `worker` WRITE;
/*!40000 ALTER TABLE `worker` DISABLE KEYS */;
/*!40000 ALTER TABLE `worker` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-12  0:51:53
