import 'dart:io';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;

import '../../../../core/di/injection.dart';
import '../../../../shared/utils/app_file_downloader.dart';
import '../../domain/entities/department_transaction_entity.dart';
import '../../domain/usecases/get_department_transactions.dart';

enum ExportFormat { excel, pdf }

class DeptTxExportService {
  DeptTxExportService._();

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

  /// Fetches transactions for export based on filter criteria
  static Future<List<DepartmentTransactionEntity>> fetchTransactions({
    required String statusFilter, // 'الكل' | 'منجزة' | 'مرفوضة'
    String? fromDate,
    String? toDate,
    int? departmentId,
  }) async {
    final getDepartmentTransactions = getIt<GetDepartmentTransactions>();
    final deptIdsStr = departmentId?.toString();

    final List<DepartmentTransactionEntity> results = [];

    Future<void> fetchStatus(String status) async {
      String? cursor;
      bool hasMore = true;
      int pages = 0;

      while (hasMore && pages < 20) {
        pages++;
        final res = await getDepartmentTransactions(
          status: status,
          departmentIds: deptIdsStr,
          fromDate: fromDate,
          toDate: toDate,
          cursor: cursor,
          limit: 100,
        );

        res.fold(
          (failure) {
            hasMore = false;
          },
          (data) {
            final items = data['items'] as List<dynamic>? ?? [];
            results.addAll(items.cast<DepartmentTransactionEntity>());

            final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
            final nextCursor = pagination['next_cursor'] as String?;
            final hasNext = pagination['has_next'] as bool? ?? false;

            if (hasNext && nextCursor != null && nextCursor.isNotEmpty) {
              cursor = nextCursor;
            } else {
              hasMore = false;
            }
          },
        );
      }
    }

    if (statusFilter == 'منجزة') {
      await fetchStatus('منجزة');
    } else if (statusFilter == 'مرفوضة') {
      await fetchStatus('مرفوضة');
    } else {
      // 'الكل' -> fetch both
      await fetchStatus('منجزة');
      await fetchStatus('مرفوضة');
    }

    // Sort by date descending
    results.sort((a, b) => b.date.compareTo(a.date));
    return results;
  }

  /// Generates an Excel (.xlsx) file and returns the saved file path
  static Future<String> exportToExcel({
    required List<DepartmentTransactionEntity> transactions,
    required String statusFilter,
    String? fromDate,
    String? toDate,
    String? departmentName,
  }) async {
    final xls.Workbook workbook = xls.Workbook();
    final xls.Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'معاملات الدائرة';
    sheet.isRightToLeft = true;

    // Header banner styles
    final xls.Style titleStyle = workbook.styles.add('titleStyle');
    titleStyle.bold = true;
    titleStyle.fontSize = 14;
    titleStyle.fontColor = '#054239';
    titleStyle.hAlign = xls.HAlignType.center;
    titleStyle.vAlign = xls.VAlignType.center;

    final xls.Style metaStyle = workbook.styles.add('metaStyle');
    metaStyle.fontSize = 10;
    metaStyle.fontColor = '#555555';
    metaStyle.hAlign = xls.HAlignType.center;
    metaStyle.vAlign = xls.VAlignType.center;

    final xls.Style tableHeaderStyle = workbook.styles.add('tableHeaderStyle');
    tableHeaderStyle.backColor = '#054239';
    tableHeaderStyle.fontColor = '#FFFFFF';
    tableHeaderStyle.bold = true;
    tableHeaderStyle.fontSize = 11;
    tableHeaderStyle.hAlign = xls.HAlignType.center;
    tableHeaderStyle.vAlign = xls.VAlignType.center;
    tableHeaderStyle.borders.all.lineStyle = xls.LineStyle.thin;
    tableHeaderStyle.borders.all.color = '#B9A779';

    final xls.Style cellStyle = workbook.styles.add('cellStyle');
    cellStyle.fontSize = 10;
    cellStyle.hAlign = xls.HAlignType.center;
    cellStyle.vAlign = xls.VAlignType.center;
    cellStyle.borders.all.lineStyle = xls.LineStyle.thin;
    cellStyle.borders.all.color = '#E0E0E0';

    final xls.Style cellAltStyle = workbook.styles.add('cellAltStyle');
    cellAltStyle.fontSize = 10;
    cellAltStyle.backColor = '#F9F8F5';
    cellAltStyle.hAlign = xls.HAlignType.center;
    cellAltStyle.vAlign = xls.VAlignType.center;
    cellAltStyle.borders.all.lineStyle = xls.LineStyle.thin;
    cellAltStyle.borders.all.color = '#E0E0E0';

    // 1. Title Rows
    sheet.getRangeByName('A1:I1').merge();
    sheet.getRangeByName('A1').setText('الجمهورية العربية السورية - وزارة التربية');
    sheet.getRangeByName('A1').cellStyle = titleStyle;
    sheet.setRowHeightInPixels(1, 28);

    sheet.getRangeByName('A2:I2').merge();
    final deptText = departmentName != null && departmentName.isNotEmpty
        ? 'تقرير معاملات الدائرة ($departmentName)'
        : 'تقرير معاملات الدائرة';
    sheet.getRangeByName('A2').setText(deptText);
    sheet.getRangeByName('A2').cellStyle = titleStyle;
    sheet.setRowHeightInPixels(2, 28);

    final now = DateTime.now();
    final dateStr = '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
    final dateRangeStr = (fromDate != null || toDate != null)
        ? 'الفترة: ${fromDate ?? 'البداية'} إلى ${toDate ?? 'الآن'}'
        : 'كافة الفترات الزمنية';
    final filterInfo = 'الحالة: $statusFilter | $dateRangeStr | تاريخ الاستخراج: $dateStr | إجمالي المعاملات: ${transactions.length}';

    sheet.getRangeByName('A3:I3').merge();
    sheet.getRangeByName('A3').setText(filterInfo);
    sheet.getRangeByName('A3').cellStyle = metaStyle;
    sheet.setRowHeightInPixels(3, 24);

    // 2. Table Column Headers
    final headers = [
      'م',
      'رقم المعاملة',
      'صاحب المعاملة',
      'نوع المعاملة',
      'الدائرة / القسم',
      'المرحلة / المهمة الحالية',
      'الحالة',
      'تاريخ المعاملة',
      'نسبة الإنجاز',
    ];

    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.getRangeByIndex(5, i + 1);
      cell.setText(headers[i]);
      cell.cellStyle = tableHeaderStyle;
    }
    sheet.setRowHeightInPixels(5, 30);

    // 3. Fill Data
    int rowIndex = 6;
    for (int i = 0; i < transactions.length; i++) {
      final tx = transactions[i];
      final currentStyle = (i % 2 == 0) ? cellStyle : cellAltStyle;

      sheet.getRangeByIndex(rowIndex, 1).setNumber((i + 1).toDouble());
      sheet.getRangeByIndex(rowIndex, 2).setText(tx.transactionNumber);
      sheet.getRangeByIndex(rowIndex, 3).setText(tx.applicantName);
      sheet.getRangeByIndex(rowIndex, 4).setText(tx.type);
      sheet.getRangeByIndex(rowIndex, 5).setText(tx.department);
      sheet.getRangeByIndex(rowIndex, 6).setText(tx.taskName.isNotEmpty ? tx.taskName : tx.processName);
      sheet.getRangeByIndex(rowIndex, 7).setText(tx.statusLabel.isNotEmpty ? tx.statusLabel : tx.status);
      sheet.getRangeByIndex(rowIndex, 8).setText(tx.date);
      sheet.getRangeByIndex(rowIndex, 9).setText('${tx.progressPercent}%');

      for (int c = 1; c <= 9; c++) {
        sheet.getRangeByIndex(rowIndex, c).cellStyle = currentStyle;
      }
      sheet.setRowHeightInPixels(rowIndex, 24);
      rowIndex++;
    }

    // Auto-fit column widths
    sheet.getRangeByIndex(5, 1, rowIndex, 9).autoFitColumns();

    // 4. Save and return path
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final dir = await AppFileDownloader.getAppDownloadsDir();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final fileName = 'تقرير_معاملات_الدائرة_$timestamp.xlsx';
    final file = File('${dir.path}${Platform.pathSeparator}$fileName');

    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// Generates a PDF file with a styled table and returns the saved file path
  static Future<String> exportToPdf({
    required List<DepartmentTransactionEntity> transactions,
    required String statusFilter,
    String? fromDate,
    String? toDate,
    String? departmentName,
  }) async {
    final document = PdfDocument();
    document.pageSettings.margins.all = 20;
    document.pageSettings.size = PdfPageSize.a4;
    document.pageSettings.orientation = PdfPageOrientation.landscape;

    try {
      // 1. Load Arabic TrueType Fonts
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

      // Setup RTL Formats
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

      // Colors
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

      // 2. Draw Top Header Banner
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
      final deptTitle = departmentName != null && departmentName.isNotEmpty
          ? 'تقرير معاملات الدائرة - $departmentName'
          : 'تقرير معاملات الدائرة';
      graphics.drawString(
        deptTitle,
        fontTitle,
        brush: PdfSolidBrush(forestColor),
        bounds: Rect.fromLTWH((pageSize.width - 360) / 2, currentY + 10, 360, 22),
        format: rtlCenterFormat,
      );

      final dateRangeStr = (fromDate != null || toDate != null)
          ? 'الفترة: ${fromDate ?? 'البداية'} إلى ${toDate ?? 'الآن'}'
          : 'كافة الفترات الزمنية';
      final subTitle = 'الحالة: $statusFilter | $dateRangeStr | إجمالي المعاملات: ${transactions.length}';
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

      // 3. Create Table (PdfGrid)
      final grid = PdfGrid();
      grid.columns.add(count: 9);

      final totalWidth = pageSize.width;
      grid.columns[0].width = totalWidth * 0.07; // الإنجاز
      grid.columns[1].width = totalWidth * 0.09; // التاريخ
      grid.columns[2].width = totalWidth * 0.08; // الحالة
      grid.columns[3].width = totalWidth * 0.16; // المهمة الحالية
      grid.columns[4].width = totalWidth * 0.14; // الدائرة
      grid.columns[5].width = totalWidth * 0.15; // نوع المعاملة
      grid.columns[6].width = totalWidth * 0.14; // صاحب المعاملة
      grid.columns[7].width = totalWidth * 0.13; // رقم المعاملة
      grid.columns[8].width = totalWidth * 0.04; // م

      // Header Row
      final headerRow = grid.headers.add(1)[0];
      final headersRtl = [
        'نسبة الإنجاز',
        'تاريخ المعاملة',
        'الحالة',
        'المرحلة / المهمة الحالية',
        'الدائرة / القسم',
        'نوع المعاملة',
        'صاحب المعاملة',
        'رقم المعاملة',
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
      for (int i = 0; i < transactions.length; i++) {
        final tx = transactions[i];
        final row = grid.rows.add();
        final isAlt = i % 2 == 1;

        final rowValues = [
          '${tx.progressPercent}%',
          tx.date,
          tx.statusLabel.isNotEmpty ? tx.statusLabel : tx.status,
          tx.taskName.isNotEmpty ? tx.taskName : tx.processName,
          tx.department,
          tx.type,
          tx.applicantName,
          tx.transactionNumber,
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

      // Draw Grid to Document
      grid.draw(
        page: page,
        bounds: Rect.fromLTWH(0, currentY, pageSize.width, pageSize.height - currentY),
      );

      // 4. Draw Footer on all pages
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
          'مستند رسمي صادر عن مديرية التربية - تقرير معاملات الدائرة - صفحة ${i + 1} من $pageCount',
          fontRegularSmall,
          brush: PdfSolidBrush(textMutedColor),
          bounds: Rect.fromLTWH(0, footerY, pSize.width, 14),
          format: rtlCenterFormat,
        );
      }

      // 5. Save to app download directory
      final pdfBytes = await document.save();
      final dir = await AppFileDownloader.getAppDownloadsDir();
      final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
      final fileName = 'تقرير_معاملات_الدائرة_$timestamp.pdf';
      final file = File('${dir.path}${Platform.pathSeparator}$fileName');

      await file.writeAsBytes(pdfBytes, flush: true);
      return file.path;
    } finally {
      document.dispose();
    }
  }
}
