class Booking {
  final String id;
  final String service;
  final String mechanic;
  final String customer;
  final String address;
  final DateTime? createdAt;
  final double price;
  final String status;
  final bool completed;

  const Booking({
    required this.id,
    required this.service,
    required this.mechanic,
    this.customer = 'Customer',
    this.address = '',
    this.createdAt,
    this.price = 0,
    this.status = 'pending',
    this.completed = false,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    final status = map['status']?.toString() ?? 'pending';
    final mechanicData = map['mechanic'];
    final customerData = map['customer'];
    final serviceData = map['service'];
    return Booking(
      id: map['id']?.toString() ?? '',
      service:
          map['service_title']?.toString() ??
          (serviceData is Map
              ? serviceData['title']?.toString() ?? 'Service'
              : 'Service'),
      mechanic: mechanicData is Map
          ? mechanicData['full_name']?.toString() ?? 'Not assigned'
          : 'Not assigned',
      customer: customerData is Map
          ? customerData['full_name']?.toString() ?? 'Customer'
          : 'Customer',
      address: map['pickup_address']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? ''),
      price:
          ((map['agreed_price'] ?? map['budget_price']) as num?)?.toDouble() ??
          0,
      status: status,
      completed: status == 'completed',
    );
  }
}
