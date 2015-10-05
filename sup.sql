-- phpMyAdmin SQL Dump
-- version 4.0.10deb1
-- http://www.phpmyadmin.net
--
-- 主機: localhost
-- 建立日期: 2015 年 10 月 03 日 02:54
-- 伺服器版本: 5.5.37-0ubuntu0.14.04.1
-- PHP 版本: 5.5.9-1ubuntu4.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- 資料庫: `sup`
--
CREATE DATABASE IF NOT EXISTS `sup` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `sup`;

-- --------------------------------------------------------

--
-- 資料表結構 `admin`
--

CREATE TABLE IF NOT EXISTS `admin` (
  `admin_username` varchar(150) NOT NULL,
  `admin_password` varchar(150) NOT NULL,
  `aid` int(10) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`aid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- 資料表結構 `broadcast`
--

CREATE TABLE IF NOT EXISTS `broadcast` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message` varchar(200) NOT NULL,
  `showing` tinyint(1) NOT NULL DEFAULT '0',
  `addtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `isImage` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=31 ;

-- --------------------------------------------------------

--
-- 資料表結構 `chatGroup`
--

CREATE TABLE IF NOT EXISTS `chatGroup` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `topicDescription` varchar(100) NOT NULL,
  `groupAdmin` varchar(50) NOT NULL,
  `interestID` int(10) NOT NULL,
  `interestDescription` varchar(200) NOT NULL,
  `locationLag` decimal(7,4) NOT NULL,
  `locationLong` decimal(7,4) NOT NULL,
  `locationName` varchar(200) DEFAULT NULL,
  `Disabled` tinyint(1) DEFAULT '0',
  `c2CallID` varchar(20) DEFAULT NULL,
  `isPublic` int(11) DEFAULT NULL,
  `topic` varchar(50) DEFAULT NULL,
  `createTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `pic` mediumblob,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=114 ;

-- --------------------------------------------------------

--
-- 資料表結構 `groupMember`
--

CREATE TABLE IF NOT EXISTS `groupMember` (
  `groupID` int(10) NOT NULL,
  `memberID` varchar(200) NOT NULL,
  `requestAccepted` tinyint(1) NOT NULL DEFAULT '0',
  `JoinTime` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 資料表結構 `interestBase`
--

CREATE TABLE IF NOT EXISTS `interestBase` (
  `interestID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `interestName` varchar(200) NOT NULL,
  PRIMARY KEY (`interestID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=24 ;

-- --------------------------------------------------------

--
-- 資料表結構 `interestCat`
--

CREATE TABLE IF NOT EXISTS `interestCat` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `interestID` int(11) unsigned NOT NULL,
  `languageCode` varchar(20) NOT NULL,
  `displayText` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- 資料表結構 `profileImage`
--

CREATE TABLE IF NOT EXISTS `profileImage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `imageData` mediumblob NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 資料表結構 `register`
--

CREATE TABLE IF NOT EXISTS `register` (
  `msisdn` varchar(200) NOT NULL,
  `brand` varchar(150) NOT NULL,
  `model` varchar(50) NOT NULL,
  `os` varchar(100) NOT NULL,
  `uid` varchar(150) NOT NULL,
  `email` varchar(250) NOT NULL,
  `pass` varchar(250) NOT NULL,
  `ver_number` int(10) DEFAULT NULL COMMENT 'verification number',
  `interestID` int(11) NOT NULL DEFAULT '-1',
  `interestDescription` varchar(200) NOT NULL DEFAULT '',
  `locationLag` decimal(7,4) NOT NULL DEFAULT '999.0000',
  `locationLong` decimal(7,4) NOT NULL DEFAULT '999.0000',
  `locationName` varchar(200) NOT NULL DEFAULT '',
  `Disabled` tinyint(1) NOT NULL DEFAULT '0',
  `apnsToken` char(64) DEFAULT NULL,
  `countryCode` varchar(20) NOT NULL,
  `phoneNo` varchar(50) NOT NULL,
  `c2CallID` varchar(20) DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `gender` char(1) DEFAULT NULL,
  `userName` varchar(100) DEFAULT NULL,
  `status` varchar(100) DEFAULT NULL,
  UNIQUE KEY `msisdn` (`msisdn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
