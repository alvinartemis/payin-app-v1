import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import 'custom_button.dart';

enum EmptyStateType { 
  noInvoices, 
  noClients, 
  noData, 
  noResults, 
  noConnection, 
  error,
  maintenance 
}

class EmptyStateWidget extends StatelessWidget {
  final EmptyStateType type;
  final String? title;
  final String? description;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Widget? customIcon;
  final Color? iconColor;
  final double? iconSize;

  const EmptyStateWidget({
    Key? key,
    required this.type,
    this.title,
    this.description,
    this.icon,
    this.actionText,
    this.onActionPressed,
    this.customIcon,
    this.iconColor,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            _buildIcon(),
            
            const SizedBox(height: AppSizes.spaceL),
            
            // Title
            Text(
              title ?? _getDefaultTitle(),
              style: const TextStyle(
                fontSize: AppSizes.fontXL,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppSizes.spaceM),
            
            // Description
            Text(
              description ?? _getDefaultDescription(),
              style: TextStyle(
                fontSize: AppSizes.fontM,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppSizes.spaceXL),
            
            // Action Button
            if (actionText != null && onActionPressed != null)
              CustomButton(
                text: actionText!,
                onPressed: onActionPressed,
                type: ButtonType.primary,
                icon: _getActionIcon(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (customIcon != null) {
      return customIcon!;
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: (iconColor ?? _getDefaultIconColor()).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Icon(
        icon ?? _getDefaultIcon(),
        size: iconSize ?? AppSizes.iconHuge,
        color: iconColor ?? _getDefaultIconColor(),
      ),
    );
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case EmptyStateType.noInvoices:
        return Icons.receipt_long_outlined;
      case EmptyStateType.noClients:
        return Icons.people_outline;
      case EmptyStateType.noData:
        return Icons.folder_outlined;
      case EmptyStateType.noResults:
        return Icons.search_off;
      case EmptyStateType.noConnection:
        return Icons.wifi_off;
      case EmptyStateType.error:
        return Icons.error_outline;
      case EmptyStateType.maintenance:
        return Icons.build_outlined;
    }
  }

  Color _getDefaultIconColor() {
    switch (type) {
      case EmptyStateType.noInvoices:
        return Colors.blue;
      case EmptyStateType.noClients:
        return Colors.green;
      case EmptyStateType.noData:
        return Colors.grey;
      case EmptyStateType.noResults:
        return Colors.orange;
      case EmptyStateType.noConnection:
        return Colors.red;
      case EmptyStateType.error:
        return AppColors.error;
      case EmptyStateType.maintenance:
        return Colors.amber;
    }
  }

  String _getDefaultTitle() {
    switch (type) {
      case EmptyStateType.noInvoices:
        return 'Belum Ada Invoice';
      case EmptyStateType.noClients:
        return 'Belum Ada Client';
      case EmptyStateType.noData:
        return 'Belum Ada Data';
      case EmptyStateType.noResults:
        return 'Tidak Ada Hasil';
      case EmptyStateType.noConnection:
        return 'Tidak Ada Koneksi';
      case EmptyStateType.error:
        return 'Terjadi Kesalahan';
      case EmptyStateType.maintenance:
        return 'Sedang Maintenance';
    }
  }

  String _getDefaultDescription() {
    switch (type) {
      case EmptyStateType.noInvoices:
        return 'Mulai buat invoice pertama Anda untuk client. Invoice yang dibuat akan muncul di sini.';
      case EmptyStateType.noClients:
        return 'Tambahkan client pertama Anda untuk mulai membuat invoice dan mengelola bisnis.';
      case EmptyStateType.noData:
        return 'Data akan muncul di sini setelah Anda mulai menggunakan aplikasi.';
      case EmptyStateType.noResults:
        return 'Coba ubah kata kunci pencarian atau filter yang Anda gunakan.';
      case EmptyStateType.noConnection:
        return 'Periksa koneksi internet Anda dan coba lagi.';
      case EmptyStateType.error:
        return 'Terjadi kesalahan saat memuat data. Silakan coba lagi.';
      case EmptyStateType.maintenance:
        return 'Aplikasi sedang dalam maintenance. Silakan coba lagi nanti.';
    }
  }

  IconData? _getActionIcon() {
    switch (type) {
      case EmptyStateType.noInvoices:
        return Icons.add;
      case EmptyStateType.noClients:
        return Icons.person_add;
      case EmptyStateType.noConnection:
      case EmptyStateType.error:
        return Icons.refresh;
      default:
        return null;
    }
  }
}

// Specific Empty State Widgets untuk use case umum
class NoInvoicesWidget extends StatelessWidget {
  final VoidCallback? onCreateInvoice;

  const NoInvoicesWidget({
    Key? key,
    this.onCreateInvoice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      type: EmptyStateType.noInvoices,
      actionText: 'Buat Invoice',
      onActionPressed: onCreateInvoice,
    );
  }
}

class NoSearchResultsWidget extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;

  const NoSearchResultsWidget({
    Key? key,
    required this.searchQuery,
    this.onClearSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      type: EmptyStateType.noResults,
      title: 'Tidak Ditemukan',
      description: 'Tidak ada hasil untuk "$searchQuery". Coba kata kunci lain.',
      actionText: 'Hapus Pencarian',
      onActionPressed: onClearSearch,
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    Key? key,
    this.errorMessage,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      type: EmptyStateType.error,
      description: errorMessage ?? 'Terjadi kesalahan saat memuat data. Silakan coba lagi.',
      actionText: 'Coba Lagi',
      onActionPressed: onRetry,
    );
  }
}
