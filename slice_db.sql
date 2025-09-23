-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mslice_db
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema slice_db
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `slice_db` DEFAULT CHARACTER SET utf8 ;
USE `slice_db` ;

-- -----------------------------------------------------
-- Table `slice_db`.`slice`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `slice_db`.`slice` (
  `idslice` INT NOT NULL,
  `estado` VARCHAR(45) NULL,
  `topologia` VARCHAR(45) NULL,
  `fecha_creacion` DATE NULL,
  `fecha_upload` DATE NULL,
  PRIMARY KEY (`idslice`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `slice_db`.`usuario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `slice_db`.`usuario` (
  `idusuario` INT NOT NULL,
  `nombre` VARCHAR(45) NULL,
  `contrasenia` VARCHAR(45) NULL,
  PRIMARY KEY (`idusuario`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `slice_db`.`instancia`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `slice_db`.`instancia` (
  `idinstancia` INT NOT NULL,
  `slice_idslice` INT NOT NULL,
  `estado` VARCHAR(45) NULL,
  `cpu` VARCHAR(45) NULL,
  `ram` VARCHAR(45) NULL,
  `storage` VARCHAR(45) NULL,
  PRIMARY KEY (`idinstancia`, `slice_idslice`),
  INDEX `fk_instancia_slice1_idx` (`slice_idslice` ASC) VISIBLE,
  CONSTRAINT `fk_instancia_slice1`
    FOREIGN KEY (`slice_idslice`)
    REFERENCES `slice_db`.`slice` (`idslice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `slice_db`.`usuario_has_slice`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `slice_db`.`usuario_has_slice` (
  `usuario_idusuario` INT NOT NULL,
  `slice_idslice` INT NOT NULL,
  PRIMARY KEY (`usuario_idusuario`, `slice_idslice`),
  INDEX `fk_usuario_has_slice_slice1_idx` (`slice_idslice` ASC) VISIBLE,
  INDEX `fk_usuario_has_slice_usuario_idx` (`usuario_idusuario` ASC) VISIBLE,
  CONSTRAINT `fk_usuario_has_slice_usuario`
    FOREIGN KEY (`usuario_idusuario`)
    REFERENCES `slice_db`.`usuario` (`idusuario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_usuario_has_slice_slice1`
    FOREIGN KEY (`slice_idslice`)
    REFERENCES `slice_db`.`slice` (`idslice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `slice_db`.`rol`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `slice_db`.`rol` (
  `idrol` INT NOT NULL,
  `nombre_rol` VARCHAR(45) NOT NULL,
  `usuario_idusuario` INT NOT NULL,
  PRIMARY KEY (`idrol`, `usuario_idusuario`),
  INDEX `fk_rol_usuario1_idx` (`usuario_idusuario` ASC) VISIBLE,
  CONSTRAINT `fk_rol_usuario1`
    FOREIGN KEY (`usuario_idusuario`)
    REFERENCES `slice_db`.`usuario` (`idusuario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `slice_db`.`security`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `slice_db`.`security` (
  `idsecurity` INT NOT NULL,
  `tipo` VARCHAR(45) NULL,
  `descripcion` VARCHAR(45) NULL,
  `slice_idslice` INT NOT NULL,
  PRIMARY KEY (`idsecurity`, `slice_idslice`),
  INDEX `fk_security_slice1_idx` (`slice_idslice` ASC) VISIBLE,
  CONSTRAINT `fk_security_slice1`
    FOREIGN KEY (`slice_idslice`)
    REFERENCES `slice_db`.`slice` (`idslice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `slice_db`.`interfaz`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `slice_db`.`interfaz` (
  `idinterfaz` INT NOT NULL,
  `nombre_interfaz` VARCHAR(45) NULL,
  `instancia_idinstancia` INT NOT NULL,
  `instancia_slice_idslice` INT NOT NULL,
  PRIMARY KEY (`idinterfaz`, `instancia_idinstancia`, `instancia_slice_idslice`),
  INDEX `fk_interfaz_instancia1_idx` (`instancia_idinstancia` ASC, `instancia_slice_idslice` ASC) VISIBLE,
  CONSTRAINT `fk_interfaz_instancia1`
    FOREIGN KEY (`instancia_idinstancia` , `instancia_slice_idslice`)
    REFERENCES `slice_db`.`instancia` (`idinstancia` , `slice_idslice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
