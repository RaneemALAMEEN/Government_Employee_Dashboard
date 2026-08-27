import 'dart:io';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;

import '../../../../shared/utils/app_file_downloader.dart';
import '../../domain/entities/org_node_entity.dart';
import '../../domain/entities/organization_employee_entity.dart';

class OrgExportRow {
  final String unitName;
  final String fullPath;
  final String level;
  final String roleName;
  final String employeeName;
  final String contact;
  final String status;

  const OrgExportRow({
    required this.unitName,
    required this.fullPath,
    required this.level,
    required this.roleName,
    required this.employeeName,
    required this.contact,
    required this.status,
  });
}

class OrgHierarchyExportService {
  OrgHierarchyExportService._();

  static Future<Uint8List> _loadFontBytes(
    String primaryAsset, [
    String? secondaryAsset,
  ]) async {
    try {
      final ByteData byteData = await rootBundle.load(primaryAsset);
      return byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );
    } catch (_) {
      if (secondaryAsset != null) {
        try {
          final ByteData fallbackData = await rootBundle.load(secondaryAsset);
          return fallbackData.buffer.asUint8List(
            fallbackData.offsetInBytes,
            fallbackData.lengthInBytes,
          );
        } catch (_) {}
      }
      final ByteData lastResort =
          await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      return lastResort.buffer.asUint8List(
        lastResort.offsetInBytes,
        lastResort.lengthInBytes,
      );
    }
  }

  /// Flattens the hierarchy tree into a linear list of rows for export
  static List<OrgExportRow> flattenHierarchy(List<OrgNodeEntity> nodes) {
    final List<OrgExportRow> rows = [];

    void traverse(OrgNodeEntity node, String currentPath) {
      final newPath = currentPath.isEmpty
          ? node.title
          : '$currentPath / ${node.title}';

      String levelStr = 'قسم / دائرة';
      if (node.type == OrgNodeType.section) {
        levelStr = 'شعبة / فرع';
      } else if (node.type == OrgNodeType.role) {
        levelStr = 'دور وظيفي';
      } else if (node.type == OrgNodeType.employee) {
        levelStr = 'موظف';
      }

      final OrganizationEmployeeEntity? emp = node.employee;
      final bool isLeaf = node.children.isEmpty;

      if (node.type == OrgNodeType.employee && emp != null) {
        rows.add(OrgExportRow(
          unitName: currentPath.split(' / ').firstOrNull ?? node.title,
          fullPath: currentPath,
          level: 'موظف',
          roleName: node.subtitle ?? '-',
          employeeName: emp.fullName,
          contact: emp.email.isNotEmpty ? emp.email : (emp.phoneNumber.isNotEmpty ? emp.phoneNumber : emp.userName),
          status: emp.isActive ? 'نشط' : 'غير نشط',
        ));
      } else if (node.type == OrgNodeType.role) {
        if (isLeaf) {
          rows.add(OrgExportRow(
            unitName: currentPath.split(' / ').firstOrNull ?? node.title,
            fullPath: currentPath,
            level: 'دور وظيفي',
            roleName: node.title,
            employeeName: 'شاغر / غير مسند',
            contact: node.subtitle ?? '-',
            status: 'متاح',
          ));
        }
      } else {
        // Department / Section
        if (isLeaf) {
          rows.add(OrgExportRow(
            unitName: node.title,
            fullPath: newPath,
            level: levelStr,
            roleName: '-',
            employeeName: '-',
            contact: '-',
            status: 'نشط',
          ));
        } else {
          // If all children are also departments/sections, keep traversing
          bool hasSubUnits = node.children.any((c) =>
              c.type == OrgNodeType.department || c.type == OrgNodeType.section);
          if (!hasSubUnits && node.children.isEmpty) {
            rows.add(OrgExportRow(
              unitName: node.title,
              fullPath: newPath,
              level: levelStr,
              roleName: '-',
              employeeName: '-',
              contact: '-',
              status: 'نشط',
            ));
          }
        }
      }

      for (final child in node.children) {
        traverse(child, newPath);
      }
    }

    for (final node in nodes) {
      traverse(node, '');
    }

    return rows;
  }

  /// Exports organizational structure to Excel (.xlsx)
  static Future<String> exportToExcel({
    required List<OrgNodeEntity> nodes,
    String? organizationName,
  }) async {
    final rows = flattenHierarchy(nodes);
    final xls.Workbook workbook = xls.Workbook();
    final xls.Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'الهيكل التنظيمي';
    sheet.isRightToLeft = true;

    // Styles
    final xls.Style titleStyle = workbook.styles.add('orgTitleStyle');
    titleStyle.bold = true;
    titleStyle.fontSize = 14;
    titleStyle.fontColor = '#054239';
    titleStyle.hAlign = xls.HAlignType.center;
    titleStyle.vAlign = xls.VAlignType.center;

    final xls.Style metaStyle = workbook.styles.add('orgMetaStyle');
    metaStyle.fontSize = 10;
    metaStyle.fontColor = '#555555';
    metaStyle.hAlign = xls.HAlignType.center;
    metaStyle.vAlign = xls.VAlignType.center;

    final xls.Style tableHeaderStyle = workbook.styles.add('orgTableHeaderStyle');
    tableHeaderStyle.backColor = '#054239';
    tableHeaderStyle.fontColor = '#FFFFFF';
    tableHeaderStyle.bold = true;
    tableHeaderStyle.fontSize = 11;
    tableHeaderStyle.hAlign = xls.HAlignType.center;
    tableHeaderStyle.vAlign = xls.VAlignType.center;
    tableHeaderStyle.borders.all.lineStyle = xls.LineStyle.thin;
    tableHeaderStyle.borders.all.color = '#B9A779';

    final xls.Style cellStyle = workbook.styles.add('orgCellStyle');
    cellStyle.fontSize = 10;
    cellStyle.hAlign = xls.HAlignType.center;
    cellStyle.vAlign = xls.VAlignType.center;
    cellStyle.borders.all.lineStyle = xls.LineStyle.thin;
    cellStyle.borders.all.color = '#E0E0E0';

    final xls.Style cellAltStyle = workbook.styles.add('orgCellAltStyle');
    cellAltStyle.fontSize = 10;
    cellAltStyle.backColor = '#F9F8F5';
    cellAltStyle.hAlign = xls.HAlignType.center;
    cellAltStyle.vAlign = xls.VAlignType.center;
    cellAltStyle.borders.all.lineStyle = xls.LineStyle.thin;
    cellAltStyle.borders.all.color = '#E0E0E0';

    // 1. Title Rows
    sheet.getRangeByName('A1:H1').merge();
    sheet.getRangeByName('A1').setText('الجمهورية العربية السورية - وزارة التربية');
    sheet.getRangeByName('A1').cellStyle = titleStyle;
    sheet.setRowHeightInPixels(1, 28);

    sheet.getRangeByName('A2:H2').merge();
    final orgTitle = organizationName != null && organizationName.isNotEmpty
        ? 'الهيكل التنظيمي الإداري ($organizationName)'
        : 'الهيكل التنظيمي الإداري';
    sheet.getRangeByName('A2').setText(orgTitle);
    sheet.getRangeByName('A2').cellStyle = titleStyle;
    sheet.setRowHeightInPixels(2, 28);

    final now = DateTime.now();
    final dateStr = '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
    final metaInfo = 'تقرير شامل لجميع الوحدات الإدارية والمسميات الوظيفية | تاريخ الاستخراج: $dateStr | إجمالي السجلات: ${rows.length}';

    sheet.getRangeByName('A3:H3').merge();
    sheet.getRangeByName('A3').setText(metaInfo);
    sheet.getRangeByName('A3').cellStyle = metaStyle;
    sheet.setRowHeightInPixels(3, 24);

    // 2. Table Headers
    final headers = [
      'م',
      'اسم الوحدة / القسم',
      'المسار الإداري الكامل',
      'المستوى التنظيمي',
      'المسمى الوظيفي / الدور',
      'اسم الموظف / المسؤول',
      'البريد / وسيلة التواصل',
      'الحالة',
    ];

    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.getRangeByIndex(5, i + 1);
      cell.setText(headers[i]);
      cell.cellStyle = tableHeaderStyle;
    }
    sheet.setRowHeightInPixels(5, 30);

    // 3. Fill Rows
    int rowIndex = 6;
    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      final currentStyle = (i % 2 == 0) ? cellStyle : cellAltStyle;

      sheet.getRangeByIndex(rowIndex, 1).setNumber((i + 1).toDouble());
      sheet.getRangeByIndex(rowIndex, 2).setText(row.unitName);
      sheet.getRangeByIndex(rowIndex, 3).setText(row.fullPath);
      sheet.getRangeByIndex(rowIndex, 4).setText(row.level);
      sheet.getRangeByIndex(rowIndex, 5).setText(row.roleName);
      sheet.getRangeByIndex(rowIndex, 6).setText(row.employeeName);
      sheet.getRangeByIndex(rowIndex, 7).setText(row.contact);
      sheet.getRangeByIndex(rowIndex, 8).setText(row.status);

      for (int c = 1; c <= 8; c++) {
        sheet.getRangeByIndex(rowIndex, c).cellStyle = currentStyle;
      }
      sheet.setRowHeightInPixels(rowIndex, 24);
      rowIndex++;
    }

    // Auto-fit columns
    sheet.getRangeByIndex(5, 1, rowIndex, 8).autoFitColumns();

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final dir = await AppFileDownloader.getAppDownloadsDir();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final fileName = 'الهيكل_التنظيمي_$timestamp.xlsx';
    final file = File('${dir.path}${Platform.pathSeparator}$fileName');

    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// Exports organizational structure to PDF (.pdf)
  static Future<String> exportToPdf({
    required List<OrgNodeEntity> nodes,
    String? organizationName,
  }) async {
    final rows = flattenHierarchy(nodes);
    final document = PdfDocument();
    document.pageSettings.margins.all = 20;
    document.pageSettings.size = PdfPageSize.a4;
    document.pageSettings.orientation = PdfPageOrientation.landscape;

    try {
      final regularFontBytes = await _loadFontBytes(
        'assets/fonts/Arial-Regular.ttf',
        'assets/fonts/Tahoma-Regular.ttf',
      );
      final boldFontBytes = await _loadFontBytes(
        'assets/fonts/Arial-Bold.ttf',
        'assets/fonts/Tahoma-Bold.ttf',
      );

      final fontRegularSmall = PdfTrueTypeFont(regularFontBytes, 7.5);
      final fontRegular = PdfTrueTypeFont(regularFontBytes, 8.5);
      final fontBold = PdfTrueTypeFont(boldFontBytes, 9.0);
      final fontTitle = PdfTrueTypeFont(boldFontBytes, 14.0);
      final fontSubtitle = PdfTrueTypeFont(boldFontBytes, 10.0);

      final rtlRightFormat = PdfStringFormat(
        textDirection: PdfTextDirection.rightToLeft,
        alignment: PdfTextAlignment.right,
        lineAlignment: PdfVerticalAlignment.middle,
      );
      final rtlCenterFormat = PdfStringFormat(
        textDirection: PdfTextDirection.rightToLeft,
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      );
      final rtlLeftFormat = PdfStringFormat(
        textDirection: PdfTextDirection.rightToLeft,
        alignment: PdfTextAlignment.left,
        lineAlignment: PdfVerticalAlignment.middle,
      );

      final forestColor = PdfColor(5, 66, 57);
      final goldColor = PdfColor(185, 167, 121);
      final goldLightColor = PdfColor(248, 246, 240);
      final textMutedColor = PdfColor(90, 90, 90);
      final borderColor = PdfColor(215, 210, 198);
      final whiteColor = PdfColor(255, 255, 255);
      final altRowColor = PdfColor(249, 248, 245);

      final page = document.pages.add();
      final graphics = page.graphics;
      final pageSize = page.getClientSize();

      double currentY = 0;

      // 1. Top Header Banner
      final headerRect = Rect.fromLTWH(0, currentY, pageSize.width, 60);
      graphics.drawRectangle(
        brush: PdfSolidBrush(goldLightColor),
        pen: PdfPen(goldColor, width: 1.2),
        bounds: headerRect,
      );

      // Right: State text
      graphics.drawString(
        'الجمهورية العربية السورية\nوزارة التربية',
        fontBold,
        brush: PdfSolidBrush(forestColor),
        bounds: Rect.fromLTWH(pageSize.width - 180, currentY + 8, 170, 44),
        format: rtlRightFormat,
      );

      // Center: Title
      final orgTitle = organizationName != null && organizationName.isNotEmpty
          ? 'الهيكل التنظيمي الإداري - $organizationName'
          : 'الهيكل التنظيمي الإداري';
      graphics.drawString(
        orgTitle,
        fontTitle,
        brush: PdfSolidBrush(forestColor),
        bounds: Rect.fromLTWH((pageSize.width - 380) / 2, currentY + 10, 380, 22),
        format: rtlCenterFormat,
      );

      final subTitle = 'شامل للوحدات التنظيمية والمسميات الوظيفية | إجمالي السجلات: ${rows.length}';
      graphics.drawString(
        subTitle,
        fontSubtitle,
        brush: PdfSolidBrush(textMutedColor),
        bounds: Rect.fromLTWH((pageSize.width - 400) / 2, currentY + 34, 400, 18),
        format: rtlCenterFormat,
      );

      // Left: Extraction Date
      final now = DateTime.now();
      final dateStr = 'تاريخ الاستخراج:\n${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
      graphics.drawString(
        dateStr,
        fontRegularSmall,
        brush: PdfSolidBrush(textMutedColor),
        bounds: Rect.fromLTWH(10, currentY + 12, 140, 36),
        format: rtlLeftFormat,
      );

      currentY += 72;

      // 2. PdfGrid Table
      final grid = PdfGrid();
      grid.columns.add(count: 8);

      final totalWidth = pageSize.width;
      grid.columns[0].width = totalWidth * 0.08; // الحالة (leftmost)
      grid.columns[1].width = totalWidth * 0.15; // التواصل
      grid.columns[2].width = totalWidth * 0.16; // اسم الموظف
      grid.columns[3].width = totalWidth * 0.14; // المسمى الوظيفي
      grid.columns[4].width = totalWidth * 0.10; // المستوى
      grid.columns[5].width = totalWidth * 0.18; // المسار الكامل
      grid.columns[6].width = totalWidth * 0.15; // اسم الوحدة
      grid.columns[7].width = totalWidth * 0.04; // م (rightmost)

      // Header Row
      final headerRow = grid.headers.add(1)[0];
      final headersRtl = [
        'الحالة',
        'البريد / وسيلة التواصل',
        'اسم الموظف / المسؤول',
        'المسمى الوظيفي / الدور',
        'المستوى',
        'المسار الإداري الكامل',
        'اسم الوحدة / القسم',
        'م',
      ];

      for (int i = 0; i < headersRtl.length; i++) {
        headerRow.cells[i].value = headersRtl[i];
        headerRow.cells[i].stringFormat = rtlCenterFormat;
        headerRow.cells[i].style.font = fontBold;
        headerRow.cells[i].style.backgroundBrush = PdfSolidBrush(forestColor);
        headerRow.cells[i].style.textBrush = PdfSolidBrush(whiteColor);
        headerRow.cells[i].style.borders.all = PdfPen(borderColor, width: 0.7);
        headerRow.cells[i].style.cellPadding = PdfPaddings(left: 3, right: 3, top: 5, bottom: 5);
      }

      // Add Data Rows
      for (int i = 0; i < rows.length; i++) {
        final rowItem = rows[i];
        final row = grid.rows.add();
        final isAlt = i % 2 == 1;

        final rowValues = [
          rowItem.status,
          rowItem.contact,
          rowItem.employeeName,
          rowItem.roleName,
          rowItem.level,
          rowItem.fullPath,
          rowItem.unitName,
          '${i + 1}',
        ];

        for (int c = 0; c < rowValues.length; c++) {
          row.cells[c].value = rowValues[c];
          row.cells[c].stringFormat = rtlCenterFormat;
          row.cells[c].style.font = fontRegular;
          row.cells[c].style.borders.all = PdfPen(borderColor, width: 0.5);
          row.cells[c].style.cellPadding = PdfPaddings(left: 3, right: 3, top: 4, bottom: 4);
          if (isAlt) {
            row.cells[c].style.backgroundBrush = PdfSolidBrush(altRowColor);
          }
        }
      }

      // Draw Grid
      grid.draw(
        page: page,
        bounds: Rect.fromLTWH(0, currentY, pageSize.width, pageSize.height - currentY),
      );

      // 3. Draw Footer on all pages
      final pageCount = document.pages.count;
      for (int i = 0; i < pageCount; i++) {
        final p = document.pages[i];
        final pSize = p.getClientSize();
        final footerY = pSize.height - 15;

        p.graphics.drawLine(
          PdfPen(borderColor, width: 0.8),
          Offset(0, footerY - 4),
          Offset(pSize.width, footerY - 4),
        );

        p.graphics.drawString(
          'مستند رسمي صادر عن مديرية التربية - الهيكل التنظيمي - صفحة ${i + 1} من $pageCount',
          fontRegularSmall,
          brush: PdfSolidBrush(textMutedColor),
          bounds: Rect.fromLTWH(0, footerY, pSize.width, 14),
          format: rtlCenterFormat,
        );
      }

      final pdfBytes = await document.save();
      final dir = await AppFileDownloader.getAppDownloadsDir();
      final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
      final fileName = 'الهيكل_التنظيمي_$timestamp.pdf';
      final file = File('${dir.path}${Platform.pathSeparator}$fileName');

      await file.writeAsBytes(pdfBytes, flush: true);
      return file.path;
    } finally {
      document.dispose();
    }
  }
}
