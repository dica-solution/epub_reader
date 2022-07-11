import 'dart:async';
import 'dart:convert' as convert;

import 'package:archive/archive.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart' as xml;

import '../schema/navigation/epub_metadata.dart';
import '../schema/navigation/epub_navigation.dart';
import '../schema/navigation/epub_navigation_label.dart';
import '../schema/navigation/epub_navigation_map.dart';
import '../schema/navigation/epub_navigation_point.dart';

// ignore: omit_local_variable_types

class NavigationReader {
  static String? _tocFileEntryPath;
  static Future<EpubNavigation> readNavigation(Archive epubArchive) async {
    var result = EpubNavigation();

    var tocFileEntry = epubArchive.files.cast<ArchiveFile?>().firstWhere(
          (ArchiveFile? file) =>
              file!.name.toLowerCase() == 'toc.ncx',
          orElse: () => null);
      if (tocFileEntry == null) {
        throw Exception(
            'EPUB parsing error: TOC file $_tocFileEntryPath not found in archive.');
      }
      var containerDocument =
          xml.XmlDocument.parse(convert.utf8.decode(tocFileEntry.content));


      var ncxNamespace = 'http://www.daisy.org/z3986/2005/ncx/';
      var ncxNode = containerDocument
          .findAllElements('ncx', namespace: ncxNamespace)
          .cast<xml.XmlElement?>()
          .firstWhere((xml.XmlElement? elem) => elem != null,
              orElse: () => null);
      if (ncxNode == null) {
        throw Exception(
            'EPUB parsing error: TOC file does not contain ncx element.');
      }
      
      var navMapNode = ncxNode
          .findElements('navMap', namespace: ncxNamespace)
          .cast<xml.XmlElement?>()
          .firstWhere((xml.XmlElement? elem) => elem != null,
              orElse: () => null);
      if (navMapNode == null) {
        throw Exception(
            'EPUB parsing error: TOC file does not contain navMap element.');
      }

      var navMap = await compute(readNavigationMap,navMapNode) ;
      result.NavMap = navMap;
    return result;
  }

  static EpubNavigationContent readNavigationContent(
      xml.XmlElement navigationContentNode) {
    var result = EpubNavigationContent();
    navigationContentNode.attributes
        .forEach((xml.XmlAttribute navigationContentNodeAttribute) {
      var attributeValue = navigationContentNodeAttribute.value;
      switch (navigationContentNodeAttribute.name.local.toLowerCase()) {
        case 'id':
          result.Id = attributeValue;
          break;
        case 'src':
          result.Source = attributeValue;
          break;
      }
    });
    if (result.Source == null || result.Source!.isEmpty) {
      throw Exception(
          'Incorrect EPUB navigation content: content source is missing.');
    }

    return result;
  }

  static EpubNavigationLabel readNavigationLabel(
      xml.XmlElement navigationLabelNode) {
    var result = EpubNavigationLabel();

    var navigationLabelTextNode = navigationLabelNode
        .findElements('text', namespace: navigationLabelNode.name.namespaceUri)
        .firstWhereOrNull((xml.XmlElement? elem) => elem != null);
    if (navigationLabelTextNode == null) {
      throw Exception(
          'Incorrect EPUB navigation label: label text element is missing.');
    }

    result.Text = navigationLabelTextNode.text;

    return result;
  }

  static EpubNavigationMap readNavigationMap(xml.XmlElement navigationMapNode) {
    var result = EpubNavigationMap();
    result.Points = <EpubNavigationPoint>[];
    navigationMapNode.children
        .whereType<xml.XmlElement>()
        .forEach((xml.XmlElement navigationPointNode) {
      if (navigationPointNode.name.local.toLowerCase() == 'navpoint') {
        var navigationPoint = readNavigationPoint(navigationPointNode);
        result.Points!.add(navigationPoint);
      }
    });
    return result;
  }

  static EpubNavigationPoint readNavigationPoint(
      xml.XmlElement navigationPointNode) {
    var result = EpubNavigationPoint();
    navigationPointNode.attributes
        .forEach((xml.XmlAttribute navigationPointNodeAttribute) {
      var attributeValue = navigationPointNodeAttribute.value;
      switch (navigationPointNodeAttribute.name.local.toLowerCase()) {
        case 'id':
          result.Id = attributeValue;
          break;
        case 'class':
          result.Class = attributeValue;
          break;
        case 'playorder':
          result.PlayOrder = attributeValue;
          break;
      }
    });
    if (result.Id == null || result.Id!.isEmpty) {
      throw Exception('Incorrect EPUB navigation point: point ID is missing.');
    }

    result.NavigationLabels = <EpubNavigationLabel>[];
    result.ChildNavigationPoints = <EpubNavigationPoint>[];
    navigationPointNode.children
        .whereType<xml.XmlElement>()
        .forEach((xml.XmlElement navigationPointChildNode) {
      switch (navigationPointChildNode.name.local.toLowerCase()) {
        case 'navlabel':
          var navigationLabel = readNavigationLabel(navigationPointChildNode);
          result.NavigationLabels!.add(navigationLabel);
          break;
        case 'content':
          var content = readNavigationContent(navigationPointChildNode);
          result.Content = content;
          break;
        case 'navpoint':
          var childNavigationPoint =
              readNavigationPoint(navigationPointChildNode);
          result.ChildNavigationPoints!.add(childNavigationPoint);
          break;
      }
    });

    if (result.NavigationLabels!.isEmpty) {
      throw Exception(
          'EPUB parsing error: navigation point ${result.Id} should contain at least one navigation label.');
    }
    if (result.Content == null) {
      throw Exception(
          'EPUB parsing error: navigation point ${result.Id} should contain content.');
    }

    return result;
  }
}
