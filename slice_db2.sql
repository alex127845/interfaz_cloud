-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8mb3 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`rol`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`rol` (
  `idrol` INT NOT NULL AUTO_INCREMENT,
  `nombre_rol` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`idrol`))
ENGINE = InnoDB
AUTO_INCREMENT = 6
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mydb`.`usuario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`usuario` (
  `idusuario` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(45) NULL DEFAULT NULL,
  `contrasenia` VARCHAR(128) NULL DEFAULT NULL,
  `rol_idrol` INT NOT NULL,
  PRIMARY KEY (`idusuario`, `rol_idrol`),
  INDEX `fk_usuario_rol1_idx` (`rol_idrol` ASC) VISIBLE,
  CONSTRAINT `fk_usuario_rol1`
    FOREIGN KEY (`rol_idrol`)
    REFERENCES `mydb`.`rol` (`idrol`))
ENGINE = InnoDB
AUTO_INCREMENT = 7
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mydb`.`slice`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`slice` (
  `idslice` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(100) NULL DEFAULT NULL,
  `estado` VARCHAR(45) NULL DEFAULT NULL,
  `topologia` TEXT NULL DEFAULT NULL,
  `fecha_creacion` DATE NULL DEFAULT NULL,
  `fecha_upload` DATE NULL DEFAULT NULL,
  `zonadisponibilidad` VARCHAR(45) NULL,
  `usuario_idusuario` INT NOT NULL,
  PRIMARY KEY (`idslice`, `usuario_idusuario`),
  INDEX `fk_slice_usuario1_idx` (`usuario_idusuario` ASC) VISIBLE,
  CONSTRAINT `fk_slice_usuario1`
    FOREIGN KEY (`usuario_idusuario`)
    REFERENCES `mydb`.`usuario` (`idusuario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 19
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mydb`.`imagen`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`imagen` (
  `idimagen` INT NOT NULL,
  `ruta` VARCHAR(45) NULL,
  `nombre` VARCHAR(45) NULL,
  PRIMARY KEY (`idimagen`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`vnc`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`vnc` (
  `idvnc` INT NOT NULL,
  `puerto` VARCHAR(45) NULL,
  PRIMARY KEY (`idvnc`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`worker`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`worker` (
  `idworker` INT NOT NULL,
  `nombre` VARCHAR(45) NULL,
  `puerto` VARCHAR(45) NULL,
  PRIMARY KEY (`idworker`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`instancia`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`instancia` (
  `idinstancia` INT NOT NULL AUTO_INCREMENT,
  `slice_idslice` INT NOT NULL,
  `nombre` VARCHAR(100) NULL DEFAULT NULL,
  `estado` VARCHAR(45) NULL DEFAULT NULL,
  `cpu` VARCHAR(45) NULL DEFAULT NULL,
  `ram` VARCHAR(45) NULL DEFAULT NULL,
  `storage` VARCHAR(45) NULL DEFAULT NULL,
  `salidainternet` TINYINT NULL,
  `imagen_idimagen` INT NOT NULL,
  `ip` VARCHAR(45) NULL,
  `vnc_idvnc` INT NULL,
  `worker_idworker` INT NULL,
  `vlan` VARCHAR(45) NULL,
  PRIMARY KEY (`idinstancia`, `slice_idslice`, `imagen_idimagen`, `vnc_idvnc`, `worker_idworker`),
  INDEX `fk_instancia_slice1_idx` (`slice_idslice` ASC) VISIBLE,
  INDEX `fk_instancia_imagen1_idx` (`imagen_idimagen` ASC) VISIBLE,
  INDEX `fk_instancia_vnc1_idx` (`vnc_idvnc` ASC) VISIBLE,
  INDEX `fk_instancia_worker1_idx` (`worker_idworker` ASC) VISIBLE,
  CONSTRAINT `fk_instancia_slice1`
    FOREIGN KEY (`slice_idslice`)
    REFERENCES `mydb`.`slice` (`idslice`),
  CONSTRAINT `fk_instancia_imagen1`
    FOREIGN KEY (`imagen_idimagen`)
    REFERENCES `mydb`.`imagen` (`idimagen`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_instancia_vnc1`
    FOREIGN KEY (`vnc_idvnc`)
    REFERENCES `mydb`.`vnc` (`idvnc`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_instancia_worker1`
    FOREIGN KEY (`worker_idworker`)
    REFERENCES `mydb`.`worker` (`idworker`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 63
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `mydb`.`enlace`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`enlace` (
  `idenlace` INT NOT NULL,
  `vm1` VARCHAR(45) NULL,
  `vm2` VARCHAR(45) NULL,
  PRIMARY KEY (`idenlace`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`vlan`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`vlan` (
  `idvlan` INT NOT NULL,
  `nombre` VARCHAR(45) NULL,
  `estado` VARCHAR(45) NULL,
  PRIMARY KEY (`idvlan`))
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
